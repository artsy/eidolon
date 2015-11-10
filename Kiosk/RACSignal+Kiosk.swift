import RxSwift

extension RACSignal {
    func mapNilToEmptyString() -> RACSignal {
        return map { (string) -> AnyObject! in
            if let string = string as? String {
                return string
            } else {
                return ""
            }
        }
    }

    func mapArrayLengthExistenceToBool() -> RACSignal {
        return map { (array) -> AnyObject! in
            if let array = array as? [AnyObject] {
                return array.isNotEmpty
            } else {
                return false
            }
        }
    }

    func mapNilToEmptyAttributedString() -> RACSignal {
        return map { (string) -> AnyObject! in
            if let string = string as? NSAttributedString {
                return string
            } else {
                return NSAttributedString()
            }
        }
    }

    /// Just like then() but it allows the block to return nil.
    func andThen(block: () -> RACSignal?) -> RACSignal {
        return self.then {
            return block() ?? RACSignal.empty()
        }
    }
}
