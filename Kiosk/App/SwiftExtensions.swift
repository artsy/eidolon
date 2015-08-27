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
        return UInt(self)
    }

    public func toUIntWithDefault(defaultValue: UInt) -> UInt {
        return UInt(self) ?? defaultValue
    }

    public var isNotEmpty: Bool {
        return !isEmpty
    }
}
