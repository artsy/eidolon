import Foundation
import RxSwift

typealias ShowDetailsClosure = (SaleArtwork) -> Void
typealias PresentModalClosure = (SaleArtwork) -> Void

protocol ListingsViewModelType {

    var auctionID: String { get }
    var syncInterval: NSTimeInterval { get }
    var pageSize: Int { get }
    var logSync: (NSDate) -> Void { get }
    var numberOfSaleArtworks: Int { get }

    var showSpinner: Observable<Bool>! { get }
    var gridSelected: Observable<Bool>! { get }
    var updatedContents: Observable<NSDate> { get }

    var scheduleOnBackground: (observable: Observable<AnyObject>) -> Observable<AnyObject> { get }
    var scheduleOnForeground: (observable: Observable<[SaleArtwork]>) -> Observable<[SaleArtwork]> { get }

    func saleArtworkViewModelAtIndexPath(indexPath: NSIndexPath) -> SaleArtworkViewModel
    func showDetailsForSaleArtworkAtIndexPath(indexPath: NSIndexPath)
    func presentModalForSaleArtworkAtIndexPath(indexPath: NSIndexPath)
    func imageAspectRatioForSaleArtworkAtIndexPath(indexPath: NSIndexPath) -> CGFloat?
}

// Cheating here, should be in the instance but there's only ever one instance, so ¯\_(ツ)_/¯
private let backgroundScheduler = SerialDispatchQueueScheduler(globalConcurrentQueuePriority: .Default)

class ListingsViewModel: NSObject, ListingsViewModelType {

    // These are private to the view model – should not be accessed directly
    private var saleArtworks = Variable(Array<SaleArtwork>())
    private var sortedSaleArtworks = Variable<Array<SaleArtwork>>([])

    let auctionID: String
    let pageSize: Int
    let syncInterval: NSTimeInterval
    let logSync: (NSDate) -> Void
    var scheduleOnBackground: (observable: Observable<AnyObject>) -> Observable<AnyObject>
    var scheduleOnForeground: (observable: Observable<[SaleArtwork]>) -> Observable<[SaleArtwork]>

    var numberOfSaleArtworks: Int {
        return sortedSaleArtworks.value.count
    }

    var showSpinner: Observable<Bool>!
    var gridSelected: Observable<Bool>!
    var updatedContents: Observable<NSDate> {
        return sortedSaleArtworks
            .asObservable()
            .map { $0.count > 0 }
            .ignore(false)
            .map { _ in NSDate() }
    }

    let showDetails: ShowDetailsClosure
    let presentModal: PresentModalClosure
    let provider: ProviderType

    init(provider: ProviderType,
         selectedIndex: Observable<Int>,
         showDetails: ShowDetailsClosure,
         presentModal: PresentModalClosure,
         pageSize: Int = 10,
         syncInterval: NSTimeInterval = SyncInterval,
         logSync:(NSDate) -> Void = ListingsViewModel.DefaultLogging,
         scheduleOnBackground: (observable: Observable<AnyObject>) -> Observable<AnyObject> = ListingsViewModel.DefaultScheduler(onBackground: true),
         scheduleOnForeground: (observable: Observable<[SaleArtwork]>) -> Observable<[SaleArtwork]> = ListingsViewModel.DefaultScheduler(onBackground: false),
         auctionID: String = AppSetup.sharedState.auctionID) {

        self.provider = provider
        self.auctionID = auctionID
        self.showDetails = showDetails
        self.presentModal = presentModal
        self.pageSize = pageSize
        self.syncInterval = syncInterval
        self.logSync = logSync
        self.scheduleOnBackground = scheduleOnBackground
        self.scheduleOnForeground = scheduleOnForeground

        super.init()

        setup(selectedIndex)
    }

    // MARK: Private Methods

    private func setup(selectedIndex: Observable<Int>) {

        recurringListingsRequest()
            .takeUntil(rx_deallocated)
            .bindTo(saleArtworks)
            .addDisposableTo(rx_disposeBag)

        showSpinner = sortedSaleArtworks.map { sortedSaleArtworks in
            return sortedSaleArtworks.count == 0
        }

        gridSelected = selectedIndex.map { ListingsViewModel.SwitchValues(rawValue: $0) == .Some(.Grid) }

        let distinctSaleArtworks = saleArtworks
            .asObservable()
            .distinctUntilChanged { (lhs, rhs) -> Bool in
                return lhs == rhs
            }
            .mapReplace(0) // To use in combineLatest, we must have an array of identically-typed observables. 

        [selectedIndex, distinctSaleArtworks]
            .combineLatest { ints in
                // We use distinctSaleArtworks to trigger an update, but ints[1] is unused.
                return ints[0]
            }
            .startWith(0)
            .map { selectedIndex in
                return ListingsViewModel.SwitchValues(rawValue: selectedIndex)
            }
            .filterNil()
            .map { [weak self] switchValue -> [SaleArtwork] in
                guard let me = self else { return [] }
                return switchValue.sortSaleArtworks(me.saleArtworks.value)
            }
            .bindTo(sortedSaleArtworks)
            .addDisposableTo(rx_disposeBag)

    }

    private func listingsRequestForPage(page: Int) -> Observable<AnyObject> {
        return provider.request(.AuctionListings(id: auctionID, page: page, pageSize: self.pageSize)).filterSuccessfulStatusCodes().mapJSON()
    }

    // Repeatedly calls itself with page+1 until the count of the returned array is < pageSize.
    private func retrieveAllListingsRequest(page: Int) -> Observable<AnyObject> {
        return create { [weak self] observer in
            guard let me = self else { return NopDisposable.instance }

            return me.listingsRequestForPage(page).subscribeNext { object in
                guard let array = object as? Array<AnyObject> else { return }
                guard let me = self else { return }

                // This'll either be the next page request or empty.
                let nextPage: Observable<AnyObject>

                // We must have more results to retrieve
                if array.count >= me.pageSize {
                    nextPage = me.retrieveAllListingsRequest(page+1)
                } else {
                    nextPage = empty()
                }

                just(object)
                    .concat(nextPage)
                    .subscribe(observer)
            }
        }
    }

    // Fetches all pages of the auction
    private func allListingsRequest() -> Observable<[SaleArtwork]> {
        let backgroundJSONParsing = scheduleOnBackground(observable: retrieveAllListingsRequest(1)).reduce([AnyObject]())
            { (memo, object) in
                guard let array = object as? Array<AnyObject> else { return memo }
                return memo + array
            }
            .mapToObjectArray(SaleArtwork)
            .logServerError("Sale artworks failed to retrieve+parse")
            .catchErrorJustReturn([])

        return scheduleOnForeground(observable: backgroundJSONParsing)
    }

    private func recurringListingsRequest() -> Observable<Array<SaleArtwork>> {
        let recurring = interval(syncInterval, MainScheduler.sharedInstance)
            .map { _ in NSDate() }
            .startWith(NSDate())
            .takeUntil(rx_deallocating)


        return recurring
            .doOnNext(logSync)
            .flatMap { [weak self] _ in
                return self?.allListingsRequest() ?? empty()
            }
            .map { [weak self] newSaleArtworks -> [SaleArtwork] in
                guard let me = self else { return [] }

                let currentSaleArtworks = me.saleArtworks.value

                // So we want to do here is pretty simple – if the existing and new arrays are of the same length,
                // then update the individual values in the current array and return the existing value.
                // If the array's length has changed, then we pass through the new array
                if newSaleArtworks.count == currentSaleArtworks.count {
                    if update(currentSaleArtworks, newSaleArtworks: newSaleArtworks) {
                        return currentSaleArtworks
                    }
                }

                return newSaleArtworks
            }
    }

    // MARK: Private class methods

    private class func DefaultLogging(date: NSDate) {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            logger.log("Syncing on \(date)")
        #endif
    }

    private class func DefaultScheduler<T>(onBackground background: Bool)(observable: Observable<T>) -> Observable<T> {
        if background {
            return observable.observeOn(backgroundScheduler)
        } else {
            return observable.observeOn(MainScheduler.sharedInstance)
        }
    }

    // MARK: Public methods

    func saleArtworkViewModelAtIndexPath(indexPath: NSIndexPath) -> SaleArtworkViewModel {
        return sortedSaleArtworks.value[indexPath.item].viewModel
    }

    func imageAspectRatioForSaleArtworkAtIndexPath(indexPath: NSIndexPath) -> CGFloat? {
        return sortedSaleArtworks.value[indexPath.item].artwork.defaultImage?.aspectRatio
    }

    func showDetailsForSaleArtworkAtIndexPath(indexPath: NSIndexPath) {
        showDetails(sortedSaleArtworks.value[indexPath.item])
    }

    func presentModalForSaleArtworkAtIndexPath(indexPath: NSIndexPath) {
        presentModal(sortedSaleArtworks.value[indexPath.item])
    }

    // MARK: - Switch Values

    enum SwitchValues: Int {
        case Grid = 0
        case LeastBids
        case MostBids
        case HighestCurrentBid
        case LowestCurrentBid
        case Alphabetical

        var name: String {
            switch self {
            case .Grid:
                return "Grid"
            case .LeastBids:
                return "Least Bids"
            case .MostBids:
                return "Most Bids"
            case .HighestCurrentBid:
                return "Highest Bid"
            case .LowestCurrentBid:
                return "Lowest Bid"
            case .Alphabetical:
                return "A–Z"
            }
        }

        func sortSaleArtworks(saleArtworks: [SaleArtwork]) -> [SaleArtwork] {
            switch self {
            case Grid:
                return saleArtworks
            case LeastBids:
                return saleArtworks.sort(leastBidsSort)
            case MostBids:
                return saleArtworks.sort(mostBidsSort)
            case HighestCurrentBid:
                return saleArtworks.sort(highestCurrentBidSort)
            case LowestCurrentBid:
                return saleArtworks.sort(lowestCurrentBidSort)
            case Alphabetical:
                return saleArtworks.sort(alphabeticalSort)
            }
        }

        static func allSwitchValues() -> [SwitchValues] {
            return [Grid, LeastBids, MostBids, HighestCurrentBid, LowestCurrentBid, Alphabetical]
        }

        static func allSwitchValueNames() -> [String] {
            return allSwitchValues().map{$0.name.uppercaseString}
        }
    }
}

// MARK: - Sorting Functions

protocol IntOrZeroable {
    var intOrZero: Int { get }
}

extension NSNumber: IntOrZeroable {
    var intOrZero: Int {
        return self as Int
    }
}

extension Optional where Wrapped: IntOrZeroable {
    var intOrZero: Int {
        return self.value?.intOrZero ?? 0
    }
}

func leastBidsSort(lhs: SaleArtwork, _ rhs: SaleArtwork) -> Bool {
    return (lhs.bidCount.intOrZero) < (rhs.bidCount.intOrZero)
}

func mostBidsSort(lhs: SaleArtwork, _ rhs: SaleArtwork) -> Bool {
    return !leastBidsSort(lhs, rhs)
}

func lowestCurrentBidSort(lhs: SaleArtwork, _ rhs: SaleArtwork) -> Bool {
    return (lhs.highestBidCents.intOrZero) < (rhs.highestBidCents.intOrZero)
}

func highestCurrentBidSort(lhs: SaleArtwork, _ rhs: SaleArtwork) -> Bool {
    return !lowestCurrentBidSort(lhs, rhs)
}

func alphabeticalSort(lhs: SaleArtwork, _ rhs: SaleArtwork) -> Bool {
    return lhs.artwork.sortableArtistID().caseInsensitiveCompare(rhs.artwork.sortableArtistID()) == .OrderedAscending
}

func sortById(lhs: SaleArtwork, _ rhs: SaleArtwork) -> Bool {
    return lhs.id.caseInsensitiveCompare(rhs.id) == .OrderedAscending
}

private func update(currentSaleArtworks: [SaleArtwork], newSaleArtworks: [SaleArtwork]) -> Bool {
    assert(currentSaleArtworks.count == newSaleArtworks.count, "Arrays' counts must be equal.")
    // Updating the currentSaleArtworks is easy. Both are already sorted as they came from the API (by lot #).
    // Because we assume that their length is the same, we just do a linear scan through and
    // copy values from the new to the existing.

    let saleArtworksCount = currentSaleArtworks.count

    for var i = 0; i < saleArtworksCount; i++ {
        if currentSaleArtworks[i].id == newSaleArtworks[i].id {
            currentSaleArtworks[i].updateWithValues(newSaleArtworks[i])
        } else {
            // Failure: the list was the same size but had different artworks.
            return false
        }
    }

    return true
}
