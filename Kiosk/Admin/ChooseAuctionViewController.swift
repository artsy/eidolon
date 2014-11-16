import UIKit
import ORStackView
import Artsy_UIFonts
import Artsy_UIButtons

class ChooseAuctionViewController: UIViewController {

    var auctions: [Sale]!

    override func viewDidLoad() {
        super.viewDidLoad()
        stackScrollView.backgroundColor = UIColor.whiteColor()
        stackScrollView.bottomMarginHeight = CGFloat(NSNotFound)
        stackScrollView.updateConstraints()

        let endpoint: ArtsyAPI = ArtsyAPI.ActiveAuctions

        XAppRequest(endpoint, method: .GET, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObjectArray(Sale.self)
            .subscribeNext({ [weak self] (activeSales) -> Void in
                self!.auctions = activeSales as [Sale]

                for i in 0 ..< countElements(self!.auctions) {
                    let sale = self!.auctions[i]
                    let title = " \(sale.name) - #\(sale.auctionState) - \(sale.artworkCount)"

                    let button = ARFlatButton()
                    button.setTitle(title, forState: .Normal)
                    button.setTitleColor(UIColor.blackColor(), forState: .Normal)
                    button.tag = i
                    button.rac_signalForControlEvents(.TouchUpInside).subscribeNext { (_) in
                        let defaults = NSUserDefaults.standardUserDefaults()
                        defaults.setObject(sale.id, forKey: "KioskAuctionID")
                        defaults.synchronize()
                        exit(1)
                    }

                    self!.stackScrollView.addSubview(button, withTopMargin: "12", sideMargin: "0")
                    button.constrainHeight("50")
                }
        })

    }

    @IBOutlet weak var stackScrollView: ORStackView!
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
