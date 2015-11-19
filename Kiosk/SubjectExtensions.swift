import RxSwift

extension BehaviorSubject {
    var value: Element? {
        guard let value = try? value() else { return nil }
        return value
    }
}
