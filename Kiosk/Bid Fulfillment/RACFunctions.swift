import Foundation

// Collection of stanardised mapping funtions for RAC work

func stringIsEmailAddress(text:AnyObject!) -> AnyObject! {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
    let testPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)!
    let stringContainsPlus:Bool = (text as NSString).containsString("+")
    return testPredicate.evaluateWithObject(text) && !stringContainsPlus
}

func stringIsCreditCard(text:AnyObject!) -> AnyObject! {
    let card = BPCard(number:text as String, expirationMonth:0, expirationYear:2023)
    return card.numberValid
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

func is4CharLengthString(string:AnyObject!) -> AnyObject! {
    return countElements(string as String) == 4
}

func islessThan3CharLengthString(string:AnyObject!) -> AnyObject! {
    return countElements(string as String) < 3
}

func minimum6CharString(string:AnyObject!) -> AnyObject! {
    return countElements(string as String) >= 6
}

