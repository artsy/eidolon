import RxSwift

class RegistrationPostalZipViewController: UIViewController, RegistrationSubController {
    @IBOutlet var zipCodeTextField: TextField!
    @IBOutlet var confirmButton: ActionButton!
    let finishedSignal = RACSubject()

    lazy var viewModel: GenericFormValidationViewModel = {
        let zipCodeIsValidSignal = self.zipCodeTextField.rac_textSignal().map(isZeroLengthString).not()
        return GenericFormValidationViewModel(isValidSignal: zipCodeIsValidSignal, manualInvocationSignal: self.zipCodeTextField.returnKeySignal(), finishedSubject: self.finishedSignal)
    }()

    lazy var bidDetails: BidDetails! = { self.navigationController!.fulfillmentNav().bidDetails }()

    override func viewDidLoad() {
        super.viewDidLoad()

        zipCodeTextField.text = bidDetails.newUser.zipCode
        RAC(bidDetails, "newUser.zipCode") <~ zipCodeTextField.rac_textSignal().takeUntil(viewWillDisappearSignal())
        confirmButton.rac_command = viewModel.command

        zipCodeTextField.becomeFirstResponder()
    }

    class func instantiateFromStoryboard(storyboard: UIStoryboard) -> RegistrationPostalZipViewController {
        return storyboard.viewControllerWithID(.RegisterPostalorZip) as! RegistrationPostalZipViewController
    }
}
