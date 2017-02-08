import Foundation

typealias Currency = UInt64

// Collection of stanardised mapping funtions for Rx work

func stringIsEmailAddress(_ text: String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
    let testPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
    return testPredicate.evaluate(with: text)
}

fileprivate func createFormatter(_ currencySymbol: String) -> NumberFormatter {
    let newFormatter = NumberFormatter()
    newFormatter.locale = Locale.current
    newFormatter.currencySymbol = currencySymbol
    newFormatter.numberStyle = .currency
    newFormatter.maximumFractionDigits = 0
    newFormatter.alwaysShowsDecimalSeparator = false
    return newFormatter
}

func centsToPresentableDollarsString(_ cents: Currency, currencySymbol: String) -> String {
    let formatter = createFormatter(currencySymbol)

    guard let dollars = formatter.string(from: NSDecimalNumber(mantissa: cents, exponent: -2, isNegative: false)) else {
        return ""
    }

    return dollars
}

func isZeroLength(string: String) -> Bool {
    return string.isEmpty
}

func isStringLength(in range: Range<Int>) -> (String) -> Bool {
    return { string in
        return range.contains(string.characters.count)
    }
}

func isStringOf(length: Int) -> (String) -> Bool {
    return { string in
        return string.characters.count == length
    }
}

func isStringLengthAtLeast(length: Int) -> (String) -> Bool {
    return { string in
        return string.characters.count >= length
    }
}

func isStringLength(oneOf lengths: [Int]) -> (String) -> Bool {
    return { string in
        return lengths.contains(string.characters.count)
    }
}

// Useful for mapping an Observable<Whatever> into an Observable<Void> to hide details.
func void<T>(_: T) -> Void {
    return Void()
}
