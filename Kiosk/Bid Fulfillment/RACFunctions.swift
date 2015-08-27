import Foundation

// Collection of stanardised mapping funtions for RAC work

func stringIsEmailAddress(text: AnyObject!) -> AnyObject! {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
    let testPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
    return testPredicate.evaluateWithObject(text)
}

func centsToPresentableDollarsString(cents:AnyObject!) -> AnyObject! {
    if let cents = cents as? Int {
        if let dollars = NSNumberFormatter.currencyStringForCents(cents) {
            return dollars
        }
    }
    return ""
}

func isZeroLengthString(string: AnyObject!) -> AnyObject! {
    return (string as! String).isEmpty
}

func isStringLengthIn(range: Range<Int>)(string: AnyObject!) -> AnyObject! {
    return range.contains((string as! String).characters.count)
}

func isStringOfLength(length: Int)(string: AnyObject!) -> AnyObject! {
    return (string as! String).characters.count == length
}

func isStringLengthAtLeast(length: Int)(string: AnyObject!) -> AnyObject! {
    return (string as! String).characters.count >= length
}

func isStringLengthOneOf(lengths: [Int])(string: AnyObject!) -> AnyObject! {
    return lengths.contains((string as! String).characters.count)
}
