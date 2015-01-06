import UIKit
import ReactiveCocoa
import Moya
import Swift_RAC_Macros

class RegistrationPasswordViewController: UIViewController, RegistrationSubController {

    @IBOutlet var passwordTextField: TextField!
    @IBOutlet var confirmButton: ActionButton!
    @IBOutlet var subtitleLabel: UILabel!
    let finishedSignal = RACSubject()
    var isLoggingIn = false

    override func viewDidLoad() {
        super.viewDidLoad()

        if let bidDetails = self.navigationController?.fulfillmentNav().bidDetails {

            let passwordTextSignal = passwordTextField.rac_textSignal()
            RAC(bidDetails, "newUser.password") <~ passwordTextSignal

            RAC(confirmButton, "enabled") <~ passwordTextSignal.map(minimum6CharString)


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
