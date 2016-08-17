import Foundation

// Collection of stanardised mapping funtions for Rx work

func stringIsEmailAddress(text: String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
    let testPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
    return testPredicate.evaluateWithObject(text)
}

func centsToPresentableDollarsString(cents: Int) -> String {
    guard let dollars = NSNumberFormatter.currencyStringForCents(cents) else {
        return ""
    }

    return dollars
}

func isZeroLengthString(string: String) -> Bool {
    return string.isEmpty
}

func isStringLengthIn(range: Range<Int>) -> (String) -> Bool {
    return { string in
        return range.contains(string.characters.count)
    }
}

func isStringOfLength(length: Int) -> (String) -> Bool {
    return { string in
        return string.characters.count == length
    }
}

func isStringLengthAtLeast(length: Int) -> (String) -> Bool {
    return { string in
        return string.characters.count >= length
    }
}

func isStringLengthOneOf(lengths: [Int]) -> (String) -> Bool {
    return { string in
        return lengths.contains(string.characters.count)
    }
}

// Useful for mapping an Observable<Whatever> into an Observable<Void> to hide details.
func void<T>(_: T) -> Void {
    return Void()
}
