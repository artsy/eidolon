import UIKit
import RxSwift

class RegistrationMobileViewController: UIViewController, RegistrationSubController, UITextFieldDelegate {
    
    @IBOutlet var numberTextField: TextField!
    @IBOutlet var confirmButton: ActionButton!
    let finished = PublishSubject<Void>()

    lazy var viewModel: GenericFormValidationViewModel = {
        let numberIsValid = self.numberTextField.rx_text.map(isZeroLengthString).not()
        return GenericFormValidationViewModel(isValid: numberIsValid, manualInvocation: self.numberTextField.rx_returnKey, finishedSubject: self.finished)
    }()

    private let _viewWillDisappear = PublishSubject<Void>()
    var viewWillDisappear: Observable<Void> {
        return self._viewWillDisappear.asObserver()
    }

    lazy var bidDetails: BidDetails! = { self.navigationController!.fulfillmentNav().bidDetails }()

    override func viewDidLoad() {
        super.viewDidLoad()

        numberTextField.text = bidDetails.newUser.phoneNumber.value
        numberTextField
            .rx_text
            .asObservable()
            .mapToOptional()
            .takeUntil(viewWillDisappear)
            .bindTo(bidDetails.newUser.phoneNumber)
            .addDisposableTo(rx_disposeBag)

        confirmButton.rx_action = viewModel.command

        numberTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        _viewWillDisappear.onNext()
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        // Allow delete
        if string.isEmpty { return true }

        // the API doesn't accept chars
        let notNumberChars = NSCharacterSet.decimalDigitCharacterSet().invertedSet;
        return string.stringByTrimmingCharactersInSet(notNumberChars).isNotEmpty
    }

    class func instantiateFromStoryboard(storyboard: UIStoryboard) -> RegistrationMobileViewController {
        return storyboard.viewControllerWithID(.RegisterMobile) as! RegistrationMobileViewController
    }
}
