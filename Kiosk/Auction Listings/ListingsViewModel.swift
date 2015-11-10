import Foundation
import RxSwift

typealias ShowDetailsClosure = (SaleArtwork) -> Void
typealias PresentModalClosure = (SaleArtwork) -> Void

protocol ListingsViewModelType {
    var auctionID: String { get }
    var syncInterval: NSTimeInterval { get }
    var pageSize: Int { get }
    var schedule: (RACSignal, RACScheduler) -> RACSignal { get }
    var logSync: (AnyObject!) -> Void { get }
    var numberOfSaleArtworks: Int { get }

    var showSpinnerSignal: RACSignal! { get }
    var gridSelectedSignal: RACSignal! { get }
    var updatedContentsSignal: RACSignal! { get }

    func saleArtworkViewModelAtIndexPath(indexPath: NSIndexPath) -> SaleArtworkViewModel
    func showDetailsForSaleArtworkAtIndexPath(indexPath: NSIndexPath)
    func presentModalForSaleArtworkAtIndexPath(indexPath: NSIndexPath)
    func imageAspectRatioForSaleArtworkAtIndexPath(indexPath: NSIndexPath) -> CGFloat?
}

class ListingsViewModel: NSObject, ListingsViewModelType {

    // These are private to the view model – should not be accessed directly
    private dynamic var saleArtworks = Array<SaleArtwork>()
    private dynamic var sortedSaleArtworks = Array<SaleArtwork>()

    let auctionID: String
    let pageSize: Int
    let syncInterval: NSTimeInterval
    let logSync: (AnyObject!) -> Void
    var schedule: (RACSignal, RACScheduler) -> RACSignal

    var numberOfSaleArtworks: Int {
        return saleArtworks.count
    }

    var showSpinnerSignal: RACSignal!
    var gridSelectedSignal: RACSignal!
    var updatedContentsSignal: RACSignal! {
        return RACObserve(self, "sortedSaleArtworks").distinctUntilChanged().mapArrayLengthExistenceToBool().ignore(false).map { _ -> AnyObject! in NSDate() }
    }

    let showDetails: ShowDetailsClosure
    let presentModal: PresentModalClosure

    init(selectedIndexSignal: RACSignal,
         showDetails: ShowDetailsClosure,
         presentModal: PresentModalClosure,
         pageSize: Int = 10,
         syncInterval: NSTimeInterval = SyncInterval,
         logSync: (AnyObject!) -> Void = ListingsViewModel.DefaultLogging,
         schedule: (signal: RACSignal, scheduler: RACScheduler) -> RACSignal = ListingsViewModel.DefaultScheduler,
         auctionID: String = AppSetup.sharedState.auctionID) {

        self.auctionID = auctionID
        self.showDetails = showDetails
        self.presentModal = presentModal
        self.pageSize = pageSize
        self.syncInterval = syncInterval
        self.logSync = logSync
        self.schedule = schedule

        super.init()

        setup(selectedIndexSignal)
    }

    // MARK: Private Methods

    private func setup(selectedIndexSignal: RACSignal) {
        RAC(self, "saleArtworks") <~ recurringListingsRequestSignal().takeUntil(self.rac_willDeallocSignal())

        showSpinnerSignal = RACObserve(self, "saleArtworks").mapArrayLengthExistenceToBool().not()
        gridSelectedSignal = selectedIndexSignal.map { return ListingsViewModel.SwitchValues(rawValue: $0 as! Int) == .Some(.Grid) }

        let sortedSaleArtworksSignal = RACSignal.combineLatest([RACObserve(self, "saleArtworks").distinctUntilChanged(), selectedIndexSignal]).map {
            let tuple = $0 as! RACTuple
            let saleArtworks = tuple.first as! [SaleArtwork]
            let selectedIndex = tuple.second as! Int

            if let switchValue = ListingsViewModel.SwitchValues(rawValue: selectedIndex) {
                return switchValue.sortSaleArtworks(saleArtworks)
            } else {
                // Necessary for compiler – won't execute
                return saleArtworks
            }
        }

        RAC(self, "sortedSaleArtworks") <~ sortedSaleArtworksSignal
    }

    private func listingsRequestSignalForPage(page: Int) -> RACSignal {
        return XAppRequest(.AuctionListings(id: auctionID, page: page, pageSize: self.pageSize)).filterSuccessfulStatusCodes().mapJSON()
    }

    // Repeatedly calls itself with page+1 until the count of the returned array is < pageSize.
    private func retrieveAllListingsRequestSignal(page: Int) -> RACSignal {

        return RACSignal.createSignal { [weak self] (subscriber) -> RACDisposable! in
            self?.listingsRequestSignalForPage(page).subscribeNext { (object) -> () in
                if let array = object as? Array<AnyObject> {

                    var nextPageSignal = RACSignal.empty()

                    if array.count >= (self?.pageSize ?? 0) {
                        // Infer we have more results to retrieve
                        nextPageSignal = self?.retrieveAllListingsRequestSignal(page+1) ?? RACSignal.empty()
                    }

                    RACSignal.`return`(object).concat(nextPageSignal).subscribe(subscriber)
                }
            }

            return nil
        }
    }

    // Fetches all pages of the auction
    private func allListingsRequestSignal() -> RACSignal {
        return schedule(schedule(retrieveAllListingsRequestSignal(1), RACScheduler(priority: RACSchedulerPriorityDefault)).collect().map({ (object) -> AnyObject! in
            // object is an array of arrays (thanks to collect()). We need to flatten it.

            let array = object as? Array<Array<AnyObject>>
            return (array ?? []).reduce(Array<AnyObject>(), combine: +)
        }).mapToObjectArray(SaleArtwork.self).`catch`({ (error) -> RACSignal! in

            logger.log("Sale Artworks: Error handling thing: \(error.artsyServerError())")

            return RACSignal.empty()
        }), RACScheduler.mainThreadScheduler())
    }

    private func recurringListingsRequestSignal() -> RACSignal {
        let recurringSignal = RACSignal.interval(syncInterval, onScheduler: RACScheduler.mainThreadScheduler()).startWith(NSDate()).takeUntil(rac_willDeallocSignal())

        return recurringSignal.doNext(logSync).map { [weak self] _ -> AnyObject! in
                return self?.allListingsRequestSignal() ?? RACSignal.empty()
            }.switchToLatest().map { [weak self] (newSaleArtworks) -> AnyObject! in
                guard self != nil else { return [] } // Now safe to use self!

                let currentSaleArtworks = self!.saleArtworks

                func update(currentSaleArtworks: [SaleArtwork], newSaleArtworks: [SaleArtwork]) -> Bool {
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

                // So we want to do here is pretty simple – if the existing and new arrays are of the same length,
                // then update the individual values in the current array and return the existing value.
                // If the array's length has changed, then we pass through the new array
                if let newSaleArtworks = newSaleArtworks as? Array<SaleArtwork> {
                    if newSaleArtworks.count == currentSaleArtworks.count {
                        if update(currentSaleArtworks, newSaleArtworks: newSaleArtworks) {
                            return currentSaleArtworks
                        }
                    }
                }

                return newSaleArtworks
        }
    }

    // MARK: Private class methods

    private class func DefaultLogging(date: AnyObject!) {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            logger.log("Syncing on \(date)")
        #endif
    }

    private class func DefaultScheduler(signal: RACSignal, _ scheduler: RACScheduler) -> RACSignal {
        return signal.deliverOn(scheduler)
    }

    // MARK: Public methods

    func saleArtworkViewModelAtIndexPath(indexPath: NSIndexPath) -> SaleArtworkViewModel {
        return sortedSaleArtworks[indexPath.item].viewModel
    }

    func imageAspectRatioForSaleArtworkAtIndexPath(indexPath: NSIndexPath) -> CGFloat? {
        return sortedSaleArtworks[indexPath.item].artwork.defaultImage?.aspectRatio
    }

    func showDetailsForSaleArtworkAtIndexPath(indexPath: NSIndexPath) {
        showDetails(sortedSaleArtworks[indexPath.item])
    }

    func presentModalForSaleArtworkAtIndexPath(indexPath: NSIndexPath) {
        presentModal(sortedSaleArtworks[indexPath.item])
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

func leastBidsSort(lhs: SaleArtwork, _ rhs: SaleArtwork) -> Bool {
    return (lhs.bidCount ?? 0) < (rhs.bidCount ?? 0)
}

func mostBidsSort(lhs: SaleArtwork, _ rhs: SaleArtwork) -> Bool {
    return !leastBidsSort(lhs, rhs)
}

func lowestCurrentBidSort(lhs: SaleArtwork, _ rhs: SaleArtwork) -> Bool {
    return (lhs.highestBidCents ?? 0) < (rhs.highestBidCents ?? 0)
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
