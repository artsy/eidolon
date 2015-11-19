import RxSwift

extension Observable where Element: Equatable {
    func ignore(value: Element) -> Observable<Element> {
        return filter({ (e) -> Bool in
            return value != e
        })
    }
}

extension Observable {
    // OK, so the idea is that I have a Variable that exposes an Observable and I want
    // to switch to the latest without mapping.
    //
    // viewModel.flatMap { saleArtworkViewModel in return saleArtworkViewModel.lotNumberSignal }
    //
    // Becomes...
    //
    // viewModel.flatMap(SaleArtworkViewModel.lotNumberSignal)
    //
    // Still not sure if this is a good idea.

    func flatMap<R>(selector: Element -> () -> Observable<R>) -> Observable<R> {
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
                return just(value)
            } else {
                return empty()
            }
        }
    }

    func replaceNilWith(nilValue: Element.Wrapped) -> Observable<Element.Wrapped> {
        return flatMap { (element) -> Observable<Element.Wrapped> in
            if let value = element.value {
                return just(value)
            } else {
                return just(nilValue)
            }
        }
    }
}

extension Observable {
    func doOnNext(closure: Element -> Void) -> Observable<Element> {
        return doOn { (event: Event) -> Void in
            switch event {
            case .Next(let value):
                closure(value)
            default: break
            }
        }
    }

    func doOnCompleted(closure: () -> Void) -> Observable<Element> {
        return doOn { (event: Event) -> Void in
            switch event {
            case .Completed:
                closure()
            default: break
            }
        }
    }
}
