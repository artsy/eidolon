import RxSwift

extension ObservableType {
    // Due to this change: https://github.com/ReactiveX/RxSwift/commit/b9e708f68169dc0bd0e5bdf623b18ea9af16b646#diff-8817eff017bb931ec361d847da28994fL11
    // Might be rolled back at some point and we can get rid of this.

    @warn_unused_result(message="Yo, put this in a dispose bag")
    public func bindTo(variable: Variable<E>) -> Disposable {
        return subscribeNext { value in
            variable.value = value
        }
    }
}
