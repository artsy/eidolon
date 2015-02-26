import ReactiveCocoa

extension RACSignal {
    func notNil() -> RACSignal {
        return map { $0 != nil }
    }

    // This is useful when we need to wait for the next invocation of the run loop,
    // often because view controller hierarchies need to stabilise.
    func dispatchAsyncMainScheduler() -> RACSignal {
        return deliverOn(RACScheduler.mainThreadScheduler())
    }
}

// This is useful when we're creating a signal and want to send completed at the next invocation of the run loop.
func sendDispatchCompleted(subscriber: RACSubscriber) {
    let signal = RACSignal.empty().dispatchAsyncMainScheduler()
    signal.subscribe(subscriber)
}

