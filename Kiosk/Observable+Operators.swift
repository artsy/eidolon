import RxSwift

//extension Observable {
//    class func ifTrue<E>(condition: Observable<Bool>, then: Observable<E>, otherwise: Observable<E>) -> Observable<E> {
//        return deferred { () -> Observable<E> in
//            condition.take(1).flatMap({ (c) -> Observable<E> in
//                if c {
//                    return then
//                } else {
//                    return otherwise
//                }
//            })
//        }
//    }
//}

extension Observable where Element: Equatable {
    func ignore(value: Element) -> Observable<Element> {
        return filter({ (e) -> Bool in
            return value != e
        })
    }
}
