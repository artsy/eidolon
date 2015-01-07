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
            if let array = array as? [AnyObject] {
                return countElements(array) > 0
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

}
