import UIKit

enum RegistrationIndex {
    case MobileVC
    case EmailVC
    case PasswordVC
    case CreditCardVC
    case ZipCodeVC
    case ConfirmVC
    
    func toInt() -> Int {
        switch (self) {
            case MobileVC: return 0
            case EmailVC: return 1
            case PasswordVC: return 1
            case CreditCardVC: return 2
            case ZipCodeVC: return 3
            case ConfirmVC: return 4
        }
    }
}

class RegistrationCoordinator: NSObject {

    dynamic var currentIndex: Int = 0
    
    func viewControllerForIndex(index: RegistrationIndex) -> UIViewController {
        let storyboard = UIStoryboard.fulfillment()
        currentIndex = index.toInt()
        
        switch index {

        case .MobileVC:
            return storyboard.viewControllerWithID(.RegisterMobile)

        case .EmailVC:
            return storyboard.viewControllerWithID(.RegisterEmail)

        case .PasswordVC:
            return storyboard.viewControllerWithID(.RegisterPassword)

        case .CreditCardVC:
            return storyboard.viewControllerWithID(.RegisterCreditCard)

        case .ZipCodeVC:
            return storyboard.viewControllerWithID(.RegisterPostalorZip)

        case .ConfirmVC:
            return storyboard.viewControllerWithID(.RegisterConfirm)
        }
    }

    func nextViewControllerForBidDetails(details:BidDetails) -> UIViewController {
        if notSet(details.newUser.phoneNumber) {
            return viewControllerForIndex(.MobileVC)
        }

        if notSet(details.newUser.email) {
            return viewControllerForIndex(.EmailVC)
        }

        if notSet(details.newUser.password) {
            return viewControllerForIndex(.PasswordVC)
        }

        if notSet(details.newUser.creditCardToken) {
            return viewControllerForIndex(.CreditCardVC)
        }

        if notSet(details.newUser.zipCode) {
            return viewControllerForIndex(.ZipCodeVC)
        }

        return viewControllerForIndex(.ConfirmVC)
    }
}

private func notSet(string:String?) -> Bool {
    if let realString = string {
        return (countElements(realString as String) == 0)
    }
    return true
}
