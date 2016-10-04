import UIKit
import ORStackView
import FLKAutoLayout
import Artsy_UIFonts
import Artsy_UIButtons

class ChooseAuctionViewController: UIViewController {

    var auctions: [Sale]!
    let provider = appDelegate().provider

    override func viewDidLoad() {
        super.viewDidLoad()
        stackScrollView.backgroundColor = .white
        stackScrollView.bottomMarginHeight = CGFloat(NSNotFound)
        stackScrollView.updateConstraints()

        let endpoint: ArtsyAPI = ArtsyAPI.activeAuctions

        provider.request(endpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapTo(arrayOf: Sale.self)
            .subscribeNext { activeSales in
                self.auctions = activeSales

                for i in 0 ..< self.auctions.count {
                    let sale = self.auctions[i]
                    let title = " \(sale.name) - #\(sale.auctionState) - \(sale.artworkCount)"

                    let button = ARFlatButton()
                    button.setTitle(title, forState: .normal)
                    button.setTitleColor(.blackColor(), forState: .normal)
                    button.tag = i
                    button.rx.tap.subscribeNext { (_) in
                        let defaults = NSUserDefaults.standardUserDefaults()
                        defaults.setObject(sale.id, forKey: "KioskAuctionID")
                        defaults.synchronize()
                        exit(1)
                        }
                        .addDisposableTo(self.rx_disposeBag)

                    self.stackScrollView.addSubview(button, withTopMargin: "12", sideMargin: "0")
                    button.constrainHeight("50")
                }
            }
            .addDisposableTo(rx_disposeBag)
        
    }

    @IBOutlet weak var stackScrollView: ORStackView!
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
}
