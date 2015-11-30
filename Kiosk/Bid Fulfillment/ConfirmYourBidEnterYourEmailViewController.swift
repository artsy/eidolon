import UIKit
import RxSwift
import RxCocoa
import Action

class ConfirmYourBidEnterYourEmailViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var confirmButton: UIButton!
    @IBOutlet var bidDetailsPreviewView: BidDetailsPreviewView!

    class func instantiateFromStoryboard(storyboard: UIStoryboard) -> ConfirmYourBidEnterYourEmailViewController {
        return storyboard.viewControllerWithID(.ConfirmYourBidEnterEmail) as! ConfirmYourBidEnterYourEmailViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let emailTextSignal = emailTextField.rx_text
        let inputIsEmail = emailTextSignal.map(stringIsEmailAddress)

        let action = CocoaAction(enabledIf: inputIsEmail) { [weak self] _ in
            guard let me = self else { return empty() }

            let endpoint: ArtsyAPI = ArtsyAPI.FindExistingEmailRegistration(email: me.emailTextField.text ?? "")

            return XAppRequest(endpoint)
                .filterStatusCode(200)
                .doOnNext { _ in
                    me.performSegue(.ExistingArtsyUserFound)
                }
                .doOnError { error in

                self?.performSegue(.EmailNotFoundonArtsy)
            }.map(void)
        }

        confirmButton.rx_action = action

        let unbindSignal = action.executing.ignore(false)

        let nav = self.fulfillmentNav()

        bidDetailsPreviewView.bidDetails = nav.bidDetails

        emailTextSignal
            .asObservable()
            .mapToOptional()
            .takeUntil(unbindSignal)
            .bindTo(nav.bidDetails.newUser.email)
            .addDisposableTo(rx_disposeBag)

        emailTextField.rx_returnKey.subscribeNext { _ in
            action.execute()
        }.addDisposableTo(rx_disposeBag)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    
        self.emailTextField.becomeFirstResponder()
    }
}

private extension ConfirmYourBidEnterYourEmailViewController {

    @IBAction func dev_emailFound(sender: AnyObject) {
        performSegue(.ExistingArtsyUserFound)
    }

    @IBAction func dev_emailNotFound(sender: AnyObject) {
        performSegue(.EmailNotFoundonArtsy)
    }

}