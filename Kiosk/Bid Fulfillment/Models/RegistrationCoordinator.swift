import UIKit

enum RegistrationIndex {
    case MobileVC
    case EmailVC
    case PasswordVC
    case CreditCardVC
    case ZipCodeVC
    case ConfirmVC
}

class RegistrationCoordinator: NSObject {

    func viewControllerForIndex(index: RegistrationIndex) -> UIViewController {
        let storyboard = UIStoryboard.fulfillment()
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
