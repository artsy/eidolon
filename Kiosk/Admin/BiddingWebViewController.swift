import UIKit

class BiddingWebViewController: DZNWebViewController {

    class func instantiateFromStoryboard() -> BiddingWebViewController {
        return UIStoryboard.fulfillment().viewControllerWithID(.ArtsyWebBidding) as BiddingWebViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.webView.scalesPageToFit = true

        let nav = self.fulfillmentNav()
        let saleArtwork = nav.bidDetails.saleArtwork
        let auctionID = nav.auctionID
        let authToken = nav.xAccessToken
        let actualSite = "https://artsy.net/feature/\(auctionID)/bid/\(saleArtwork!.artwork.id)"

        let number = nav.bidDetails.bidderNumber!
        let pin = nav.bidDetails.bidderPIN!

        let endpoint: ArtsyAPI = ArtsyAPI.TrustToken(number:number, auctionPIN:pin)
        XAppRequest(endpoint, method: .POST).filterSuccessfulStatusCodes().mapJSON().subscribeNext({ [weak self] (json) -> Void in

            if let token = json["trust_token"] as? String {
                let escapedSite = actualSite.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!

                let address = "https://artsy.net/users/sign_in?trust_token=\(token)&redirect_uri=\(escapedSite)"
                println(address)
                let request = NSURLRequest(URL: NSURL(string: address)!)
                self?.webView.loadRequest(request)
            }

        })
    }
}
