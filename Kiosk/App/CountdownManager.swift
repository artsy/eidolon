import Foundation

let CountdownManagerInterval: NSTimeInterval = 0.49

public class CountdownManager: NSObject {
    dynamic var sale: Sale?

    let time = SystemTime()
    lazy var interval = CountdownManagerInterval

    /// Returns the first non-nil sale that has a non-empty id
    private lazy var nonNilSaleSignal: RACSignal = {
        return RACObserve(self, "sale").ignore(nil).filter { (object) -> Bool in
            return (object as Sale).id != ""
        }.take(1).replayLast().publish().autoconnect()
    }()

    /// Sends RACTuple (sale, time)
    private lazy var waitForSaleAndSync: RACSignal = {
        RACSignal.combineLatest([self.nonNilSaleSignal, self.syncSignal]).filter({ (object) -> Bool in
            let time = (object as RACTuple).second as SystemTime
            return time.inSync()
        }).replayLast().publish().autoconnect()
    }()

    /// Returns false until the sync is complete and we have a non-nil sale object, then returns true and completes.
    private lazy var isDefinedSignal: RACSignal = {
        self.waitForSaleAndSync.take(1).mapReplace(true).startWith(false)
    }()

    /// Signal that firest every interval and never completes
    private lazy var intervalSignal: RACSignal = {
        RACSignal.interval(self.interval, onScheduler: RACScheduler.mainThreadScheduler()).startWith(NSDate())
    }()
    /// Signal that fires with the current date every interval and completes when the auction is over
    private lazy var tickSignal: RACSignal = {
        self.intervalSignal.takeUntil(self.auctionCompleteSignal)
    }()

    /// Sends the SystemTime once it syncs
    private lazy var syncSignal: RACSignal = {
        return self.time.syncSignal().replayLast().publish().autoconnect()
    }()

    /// Completes when the auction finishes
    public lazy var auctionCompleteSignal: RACSignal = {
        return self.auctionIsActiveSignal.ignore(true).take(1).replayLast()
    }()

    /// Returns a signal that sends if the sale is active.
    /// If we are not sync'd, we assume the sale is active.
    public lazy var auctionIsActiveSignal: RACSignal = {
        let time = self.time

        // Waits for a non-nil sale value and also a sync value
        // If we're not in a defined state yet, assume that we're still active.
        let assumeActiveSignal = RACSignal.defer { RACSignal.`return`(true) }
        // If we are defined (meaning we've sync'd + have a sale), then "active" is if the sale is active
        let activeSignal = self.intervalSignal.mapReplace(self.time).map { [weak self] (time) -> AnyObject! in
            return self!.sale?.isActive(time as SystemTime) ?? true // unlikely to default to true, but let's be safe
        }.distinctUntilChanged()

        return RACSignal.`if`(self.isDefinedSignal, then: activeSignal, `else`: assumeActiveSignal).publish().autoconnect()
    }()

    /// Shared singleton instance
    public class var sharedInstance: CountdownManager {
        struct SharedManager {
            static var instance = CountdownManager()
        }

        return SharedManager.instance
    }

    /// Sends a RACTuple of (currentTime, endDate) every interval until the auction completes
    public func saleIsActiveTickSignal() -> RACSignal {
        let tickSignal = self.tickSignal
        // Wait for sync to complete and a non-nil sale object
        return waitForSaleAndSync.take(1).map { (object) -> AnyObject! in
            let tuple = object as RACTuple
            let sale = tuple.first as Sale
            let time = tuple.second as SystemTime

            return tickSignal.map { (_) -> AnyObject! in
                return RACTuple(objectsFromArray: [time.date(), sale.endDate])
            }
        }.switchToLatest()
    }
}