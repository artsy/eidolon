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
            case ZipCodeVC: return 2
            case CreditCardVC: return 3
            case ConfirmVC: return 4
        }
    }

    static func fromInt(index:Int) -> RegistrationIndex {
        switch (index) {
            case 0: return .MobileVC
            case 1: return .EmailVC
            case 1: return .PasswordVC
            case 2: return .ZipCodeVC
            case 3: return .CreditCardVC
            default : return .ConfirmVC
        }
    }
}

class RegistrationCoordinator: NSObject {

    dynamic var currentIndex: Int = 0
    var storyboard:UIStoryboard!

    func viewControllerForIndex(index: RegistrationIndex) -> UIViewController {
        currentIndex = index.toInt()
        
        switch index {

        case .MobileVC:
            return storyboard.viewControllerWithID(.RegisterMobile)

        case .EmailVC:
            return storyboard.viewControllerWithID(.RegisterEmail)

        case .PasswordVC:
            return storyboard.viewControllerWithID(.RegisterPassword)

        case .ZipCodeVC:
            return storyboard.viewControllerWithID(.RegisterPostalorZip)

        case .CreditCardVC:
            if AppSetup.sharedState.disableCardReader {
                return storyboard.viewControllerWithID(.ManualCardDetailsInput)
            } else {
                return storyboard.viewControllerWithID(.RegisterCreditCard)
            }

        case .ConfirmVC:
            return storyboard.viewControllerWithID(.RegisterConfirm)
        }
    }

    func nextViewControllerForBidDetails(details: BidDetails) -> UIViewController {
        if notSet(details.newUser.phoneNumber) {
            return viewControllerForIndex(.MobileVC)
        }

        if notSet(details.newUser.email) {
            return viewControllerForIndex(.EmailVC)
        }

        if notSet(details.newUser.password) {
            return viewControllerForIndex(.PasswordVC)
        }

        if notSet(details.newUser.zipCode) && AppSetup.sharedState.needsZipCode {
            return viewControllerForIndex(.ZipCodeVC)
        }

        if notSet(details.newUser.creditCardToken) {
            return viewControllerForIndex(.CreditCardVC)
        }

        return viewControllerForIndex(.ConfirmVC)
    }
}

private func notSet(string:String?) -> Bool {
    return string?.isEmpty ?? true
}
