import Foundation
import ReactiveCocoa
import Keys

class AdminCardTestingViewController: UIViewController {

    lazy var keys = EidolonKeys()
    var cardHandler: CardHandler!

    @IBOutlet weak var logTextView: UITextView!

     override func viewDidLoad() {
        super.viewDidLoad()


        self.logTextView.text = ""

        if AppSetup.sharedState.useStaging {
            cardHandler = CardHandler(apiKey: self.keys.cardflightStagingAPIClientKey(), accountToken: self.keys.cardflightStagingMerchantAccountToken())
        } else {
            cardHandler = CardHandler(apiKey: self.keys.cardflightProductionAPIClientKey(), accountToken: self.keys.cardflightProductionMerchantAccountToken())
        }

        cardHandler.cardSwipedSignal.subscribeNext({ (message) -> Void in
                self.log("\(message)")
                return

            }, error: { (error) -> Void in

                self.log("\n====Error====\n\(error)\nThe card reader may have become disconnected.\n\n")
                if self.cardHandler.card != nil {
                    self.log("==\n\(self.cardHandler.card!)\n\n")
                }


            }, completed: {

                if let card = self.cardHandler.card {
                    let cardDetails = "Card: \(card.name) - \(card.last4) \n \(card.cardToken)"
                    self.log(cardDetails)
                }

                self.cardHandler.startSearching()
        })

        cardHandler.startSearching()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        cardHandler.end()
    }

    func log(string: String) {
        self.logTextView.text = "\(self.logTextView.text)\n\(string)"

    }

    @IBAction func backTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }


}