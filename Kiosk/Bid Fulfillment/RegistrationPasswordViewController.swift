import UIKit
import ReactiveCocoa
import Moya
import Swift_RAC_Macros

class RegistrationPasswordViewController: UIViewController, RegistrationSubController {

    @IBOutlet var passwordTextField: TextField!
    @IBOutlet var confirmButton: ActionButton!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var forgotPasswordButton: UIButton!
    let finishedSignal = RACSubject()
    dynamic var isLoggingIn = false

    override func viewDidLoad() {
        super.viewDidLoad()

        forgotPasswordButton.hidden = false

        if let bidDetails = self.navigationController?.fulfillmentNav().bidDetails {

            let passwordTextSignal = passwordTextField.rac_textSignal()
            RAC(bidDetails, "newUser.password") <~ passwordTextSignal

            RAC(confirmButton, "enabled") <~ passwordTextSignal.map(minimum6CharString)
            RAC(forgotPasswordButton, "hidden") <~ RACObserve(self, "isLoggingIn").not()

            forgotPasswordButton.rac_command = RACCommand { (_) -> RACSignal! in
                let endpoint: ArtsyAPI = ArtsyAPI.LostPasswordNotification(email: self.navigationController!.fulfillmentNav().bidDetails.newUser.email!)
                return XAppRequest(endpoint, method: .POST, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().doNext { [weak self] (json) -> Void in
                    logger.log("Sent forgot password request")
                }.then {
                    self.alertUserPasswordSent()
                }
            }

            checkForEmailExistence(bidDetails.newUser.email!).subscribeNext { (response) in
                let moyaResponse = response as MoyaResponse

                // Account exists
                if moyaResponse.statusCode == 200 {
                    self.subtitleLabel.text = "Enter your Artsy password"
                    self.isLoggingIn = true
                }
            }
        }

        passwordTextField.returnKeySignal().subscribeNext({ [weak self] (_) -> Void in
            self?.finishedSignal.sendCompleted()
            return
        })
        passwordTextField.becomeFirstResponder()
    }

    @IBAction func confirmTapped(sender: AnyObject) {
        if !isLoggingIn {
            finishedSignal.sendCompleted()
        } else {

            let newUser = self.navigationController!.fulfillmentNav().bidDetails.newUser
            authCheckSignal(newUser.email!, password: newUser.password!).subscribeNext({ (_) -> Void in
                self.finishedSignal.sendCompleted()
                return

            }, error: { (_) -> Void in
                self.showAuthenticationError()
                return
            })
        }
    }

    func alertUserPasswordSent() -> RACSignal {
        return RACSignal.createSignal { (subscriber) -> RACDisposable! in

            let alertController = UIAlertController(title: "Forgot Password", message: "We have sent you your password.", preferredStyle: .Alert)

            let okAction = UIAlertAction(title: "OK", style: .Default) { (_) in }

            alertController.addAction(okAction)

            self.presentViewController(alertController, animated: true) {
                subscriber.sendCompleted()
            }

            return nil
        }
    }

    func checkForEmailExistence(email: String) -> RACSignal {

        let endpoint: ArtsyAPI = ArtsyAPI.FindExistingEmailRegistration(email: email)
        return Provider.sharedProvider.request(endpoint, method: .GET, parameters:endpoint.defaultParameters)
    }

    func authCheckSignal(email: String, password: String) -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.XAuth(email: email, password: password)
        return Provider.sharedProvider.request(endpoint, method:.GET, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON()
    }

    func showAuthenticationError() {
        confirmButton.flashError("Incorrect")
        passwordTextField.flashForError()
        confirmButton.setEnabled(false, animated: false)
        navigationController!.fulfillmentNav().bidDetails.newUser.password = ""
        passwordTextField.text = ""
    }
}
