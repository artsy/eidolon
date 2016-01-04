import RxSwift

extension Observable where Element: Equatable {
    func ignore(value: Element) -> Observable<Element> {
        return filter { (e) -> Bool in
            return value != e
        }
    }
}

extension Observable {
    // OK, so the idea is that I have a Variable that exposes an Observable and I want
    // to switch to the latest without mapping.
    //
    // viewModel.flatMap { saleArtworkViewModel in return saleArtworkViewModel.lotNumber }
    //
    // Becomes...
    //
    // viewModel.flatMapTo(SaleArtworkViewModel.lotNumber)
    //
    // Still not sure if this is a good idea.

    func flatMapTo<R>(selector: Element -> () -> Observable<R>) -> Observable<R> {
        return self.map { (s) -> Observable<R> in
            return selector(s)()
        }.switchLatest()
    }
}

protocol OptionalType {
    typealias Wrapped

    var value: Wrapped? { get }
}

extension Optional: OptionalType {
    var value: Wrapped? {
        return self
    }
}

extension Observable where Element: OptionalType {
    func filterNil() -> Observable<Element.Wrapped> {
        return flatMap { (element) -> Observable<Element.Wrapped> in
            if let value = element.value {
                return .just(value)
            } else {
                return .empty()
            }
        }
    }

    func replaceNilWith(nilValue: Element.Wrapped) -> Observable<Element.Wrapped> {
        return flatMap { (element) -> Observable<Element.Wrapped> in
            if let value = element.value {
                return .just(value)
            } else {
                return .just(nilValue)
            }
        }
    }
}

extension Observable {
    func doOnNext(closure: Element -> Void) -> Observable<Element> {
        return doOn { (event: Event) in
            switch event {
            case .Next(let value):
                closure(value)
            default: break
            }
        }
    }

    func doOnCompleted(closure: () -> Void) -> Observable<Element> {
        return doOn { (event: Event) in
            switch event {
            case .Completed:
                closure()
            default: break
            }
        }
    }

    func doOnError(closure: ErrorType -> Void) -> Observable<Element> {
        return doOn { (event: Event) in
            switch event {
            case .Error(let error):
                closure(error)
            default: break
            }
        }
    }
}

private let backgroundScheduler = SerialDispatchQueueScheduler(globalConcurrentQueueQOS: .Default)

extension Observable {
    func mapReplace<T>(value: T) -> Observable<T> {
        return map { _ -> T in
            return value
        }
    }

    func dispatchAsyncMainScheduler() -> Observable<E> {
        return self.observeOn(backgroundScheduler).observeOn(MainScheduler.instance)
    }
}

// Maps true to false and vice versa
extension Observable where Element: BooleanType {
    func not() -> Observable<Bool> {
        return self.map { input in
            return !input.boolValue
        }
    }
}

extension CollectionType where Generator.Element: ObservableType, Generator.Element.E: BooleanType {

    func combineLatestAnd() -> Observable<Bool> {
        return combineLatest { bools -> Bool in
            bools.reduce(true, combine: { (memo, element) in
                return memo && element.boolValue
            })
        }
    }

    func combineLatestOr() -> Observable<Bool> {
        return combineLatest { bools in
            bools.reduce(false, combine: { (memo, element) in
                return memo || element.boolValue
            })
        }
    }
}

extension ObservableType {

    func then(closure: () -> Observable<E>?) -> Observable<E> {
        return then(closure() ?? .empty())
    }

    func then(@autoclosure(escaping) closure: () -> Observable<E>) -> Observable<E> {
        let next = Observable.deferred {
            return closure() ?? .empty()
        }

        return self
            .ignoreElements()
            .concat(next)
    }
}

extension Observable {
    func mapToOptional() -> Observable<Optional<Element>> {
        return map { Optional($0) }
    }
}

func sendDispatchCompleted<T>(observer: AnyObserver<T>) {
    dispatch_async(dispatch_get_main_queue()) {
        observer.onCompleted()
    }
}
