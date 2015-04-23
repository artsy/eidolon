extension Optional {
    var hasValue: Bool {
        switch self {
        case .None:
            return false
        case .Some(_):
            return true
        }
    }
}

extension String {
    func toUInt() -> UInt? {
        let i = toInt()
        if let i = i {
            return UInt(i)
        } else {
            return nil
        }
    }

    func toUInt(#defaultValue: UInt) -> UInt {
        let i = toInt()
        if let i = i {
            return UInt(i)
        } else {
        return defaultValue
        }
    }
}
