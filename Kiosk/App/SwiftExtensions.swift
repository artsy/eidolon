import RxOptional

extension Optional {
    var hasValue: Bool {
        switch self {
        case .none:
            return false
        case .some(_):
            return true
        }
    }
}

extension String {
    func toUInt() -> UInt? {
        return UInt(self)
    }

    func toUInt(withDefault defaultValue: UInt) -> UInt {
        return UInt(self) ?? defaultValue
    }
}


// Extend the idea of occupiability to optionals. Specifically, optionals wrapping occupiable things.
// We're relying on the RxOptional pod to provide the Occupiable protocol.
extension Optional where Wrapped: Occupiable {
    var isNilOrEmpty: Bool {
        switch self {
        case .none:
            return true
        case .some(let value):
            return value.isEmpty
        }
    }

    var isNotNilNotEmpty: Bool {
        return !isNilOrEmpty
    }
}


extension NSNumber {
    var currencyValue: Currency {
        return uint64Value
    }
}
