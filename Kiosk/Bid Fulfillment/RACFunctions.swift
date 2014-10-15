import Foundation

// Collection of stanardised mapping funtions for RAC work

func stringIsEmailAddress(text:AnyObject!) -> AnyObject! {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
    let testPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)

    return testPredicate?.evaluateWithObject(text)
}

func centsToPresentableDollarsString(cents:AnyObject!) -> AnyObject! {
    if let dollars = NSNumberFormatter.currencyStringForCents(cents as? Int) {
        return dollars
    }
    return ""
}

func isZeroLengthString(string:AnyObject!) -> AnyObject! {
    return countElements(string as String) == 0
}


func longerThan4CharString(string:AnyObject!) -> AnyObject! {
    return countElements(string as String) > 4
}
