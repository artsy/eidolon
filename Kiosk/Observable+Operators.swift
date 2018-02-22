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
    // viewModel.flatMap { saleArtworkViewModel in return saleArtworkViewModel.lotLabel }
    //
    // Becomes...
    //
    // viewModel.flatMapTo(SaleArtworkViewModel.lotLabel)
    //
    // Still not sure if this is a good idea.

    func flatMapTo<R>(_ selector: @escaping (Element) -> () -> Observable<R>) -> Observable<R> {
        return self.map { (s) -> Observable<R> in
            return selector(s)()
        }.switchLatest()
    }
}

private let backgroundScheduler = SerialDispatchQueueScheduler(qos: .default)

extension Observable {
    func mapReplace<T>(with value: T) -> Observable<T> {
        return map { _ -> T in
            return value
        }
    }

    func dispatchAsyncMainScheduler() -> Observable<E> {
        return self.observeOn(backgroundScheduler).observeOn(MainScheduler.instance)
    }
}

protocol BooleanType {
    var boolValue: Bool { get }
}
extension Bool: BooleanType {
    var boolValue: Bool { return self }
}

// Maps true to false and vice versa
extension Observable where Element: BooleanType {
    func not() -> Observable<Bool> {
        return self.map { input in
            return !input.boolValue
        }
    }
}

extension Collection where Iterator.Element: ObservableType, Iterator.Element.E: BooleanType {

    func combineLatestAnd() -> Observable<Bool> {
        return Observable.combineLatest(self) { bools -> Bool in
            return bools.reduce(true, { (memo, element) in
                return memo && element.boolValue
            })
        }
    }

    func combineLatestOr() -> Observable<Bool> {
        return Observable.combineLatest(self) { bools in
            bools.reduce(false, { (memo, element) in
                return memo || element.boolValue
            })
        }
    }
}

extension ObservableType {

    func then(_ closure: @escaping () -> Observable<E>?) -> Observable<E> {
        return then(closure() ?? .empty())
    }

    func then( _ closure: @autoclosure @escaping () -> Observable<E>) -> Observable<E> {
        let next = Observable.deferred {
            return closure() 
        }

        return self
            .filter { _ in false }
            .concat(next)
    }
}

extension Observable {
    func mapToOptional() -> Observable<Optional<Element>> {
        return map { Optional($0) }
    }
}

func sendDispatchCompleted<T>(to observer: AnyObserver<T>) {
    DispatchQueue.main.async {
        observer.onCompleted()
    }
}
