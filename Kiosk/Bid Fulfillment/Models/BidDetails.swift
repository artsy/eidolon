import UIKit
import RxSwift
import Moya

@objc class BidDetails: NSObject {
    typealias DownloadImageClosure = (url: NSURL, imageView: UIImageView) -> ()

    let auctionID: String

    var newUser: NewUser = NewUser()
    var saleArtwork: SaleArtwork?

    var paddleNumber = Variable<String?>(nil)
    var bidderPIN = Variable<String?>(nil)
    var bidAmountCents = Variable<NSNumber?>(nil)
    var bidderID = Variable<String?>(nil)

    var setImage: DownloadImageClosure = { (url, imageView) -> () in
        imageView.sd_setImageWithURL(url)
    }

    init(saleArtwork: SaleArtwork?, paddleNumber: String?, bidderPIN: String?, bidAmountCents: Int?, auctionID: String) {
        self.auctionID = auctionID
        self.saleArtwork = saleArtwork
        self.paddleNumber.value = paddleNumber
        self.bidderPIN.value = bidderPIN
        self.bidAmountCents.value = bidAmountCents
    }

    /// Creates a new authenticated networking provider based on either:
    /// - User's paddle/phone # and PIN, or
    /// - User's email and password
    func authenticatedNetworking(provider: Networking) -> Observable<AuthorizedNetworking> {

        let auctionID = saleArtwork?.auctionID ?? ""

        if let number = paddleNumber.value, let pin = bidderPIN.value {
            let newEndpointsClosure = { (target: ArtsyAuthenticatedAPI) -> Endpoint<ArtsyAuthenticatedAPI> in
                // Grab existing endpoint to piggy-back off of any existing configurations being used by the sharedprovider.
                let endpoint = Networking.endpointsClosure()(target)

                return endpoint.endpointByAddingParameters(["auction_pin": pin, "number": number, "sale_id": auctionID])
            }

            let provider = OnlineProvider(endpointClosure: newEndpointsClosure, requestClosure: Networking.endpointResolver(), stubClosure: Networking.APIKeysBasedStubBehaviour, plugins: Networking.authenticatedPlugins)

            return just(AuthorizedNetworking(provider: provider))

        } else {
            let endpoint: ArtsyAPI = ArtsyAPI.XAuth(email: newUser.email.value ?? "", password: newUser.password.value ?? "")

            return provider.request(endpoint)
                .filterSuccessfulStatusCodes()
                .mapJSON()
                .flatMap { accessTokenDict -> Observable<AuthorizedNetworking> in
                    guard let accessToken = accessTokenDict["access_token"] as? String else {
                        return failWith(EidolonError.CouldNotParseJSON)
                    }

                    return just(Networking.newAuthorizedNetworking(accessToken))
                }
                .logServerError("Getting Access Token failed.")
        }
    }
}