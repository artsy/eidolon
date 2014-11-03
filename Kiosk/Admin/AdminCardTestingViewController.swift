import Foundation

class AdminCardTestingViewController: UIViewController {

    lazy var keys = EidolonKeys()

    @IBOutlet weak var logTextView: UITextView!

     override func viewDidLoad() {
        super.viewDidLoad()

        self.logTextView.text = ""

        let merchantToken = AppSetup.sharedState.useStaging ? self.keys.cardflightMerchantAccountStagingToken() : self.keys.cardflightMerchantAccountToken()
        let cardHandler = CardHandler(apiKey: self.keys.cardflightAPIClientKey(), accountToken:merchantToken)

        cardHandler.cardSwipedSignal.subscribeNext({ (message) -> Void in
                self.logTextView.text = "\(self.logTextView.text)\n\(message)"
                return
            }, error: { (error) -> Void in
                self.logTextView.text = "\(self.logTextView.text)\n\n====Error====\n\(error)\n\n"
                return

            }, completed: {

                if let card = cardHandler.card {
                    let cardDetails = "Card: \(card.name) - \(card.encryptedSwipedCardNumber) \n \(card.cardToken)"
                    self.logTextView.text = "\(self.logTextView.text)\n\(cardDetails)"
                }

                cardHandler.startSearching()
        })

        cardHandler.startSearching()
    }

    @IBAction func backTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
}