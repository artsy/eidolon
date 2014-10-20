import UIKit

class RegistrationPasswordViewController: UIViewController, RegistrationSubController {

    @IBOutlet var passwordTextField: TextField!
    @IBOutlet var confirmButton: ActionButton!
    @IBOutlet var subtitleLabel: UILabel!

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
                }
            }
        }
        
        passwordTextField.becomeFirstResponder()
    }

    let finishedSignal = RACSubject()
    @IBAction func confirmTapped(sender: AnyObject) {
        finishedSignal.sendCompleted()
    }

    func checkForEmailExistence(email: String) -> RACSignal {

        let endpoint: ArtsyAPI = ArtsyAPI.FindExistingEmailRegistration(email: email)
        return Provider.sharedProvider.request(endpoint, method: .GET, parameters:endpoint.defaultParameters)
    }

}
