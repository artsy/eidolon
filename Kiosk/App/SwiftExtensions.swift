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
    public func toUInt() -> UInt? {
        return UInt(self)
    }

    public func toUIntWithDefault(defaultValue: UInt) -> UInt {
        return UInt(self) ?? defaultValue
    }
}

// Anything that can hold a value (strings, arrays, etc)
protocol Occupiable {
    var isEmpty: Bool { get }
    var isNotEmpty: Bool { get }
}

// Give a default implementation of isNotEmpty, so conformance only requires one implementation
extension Occupiable {
    var isNotEmpty: Bool {
        return !isEmpty
    }
}

extension String: Occupiable { }

// I can't think of a way to combine these collection types. Suggestions welcome.
extension Array: Occupiable { }
extension Dictionary: Occupiable { }
extension Set: Occupiable { }

// Extend the idea of occupiability to optionals. Specifically, optionals wrapping occupiable things.
extension Optional where Wrapped: Occupiable {
    var isNilOrEmpty: Bool {
        switch self {
        case .None:
            return true
        case .Some(let value):
            return value.isEmpty
        }
    }

    var isNotNilNotEmpty: Bool {
        return !isNilOrEmpty
    }
}
