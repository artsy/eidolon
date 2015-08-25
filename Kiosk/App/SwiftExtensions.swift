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

public extension String {
    public func toUInt() -> UInt? {
        let i = Int(self)
        if let i = i {
            return UInt(i)
        } else {
            return nil
        }
    }

    public func toUInt(defaultValue: UInt) -> UInt {
        let i = Int(self)
        if let i = i {
            return UInt(i)
        } else {
        return defaultValue
        }
    }
}
