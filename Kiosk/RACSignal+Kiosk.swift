import ReactiveCocoa

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
            guard let array = array as? [AnyObject] where array.isNotEmpty else { return false }
            return true
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

}
