import Foundation
import RxSwift
import Moya

protocol BidderNetworkModelType {
    var createdNewUser: Observable<Bool> { get }
    var bidDetails: BidDetails { get }

    func createOrGetBidder() -> Observable<AuthorizedNetworkingType>
}

class BidderNetworkModel: NSObject, BidderNetworkModelType {

    let bidDetails: BidDetails
    let provider: NetworkingType

    var createdNewUser: Observable<Bool> {
        return self.bidDetails.newUser.hasBeenRegistered.asObservable()
    }

    init(provider: NetworkingType, bidDetails: BidDetails) {
        self.provider = provider
        self.bidDetails = bidDetails
    }

    // MARK: - Main observable

    /// Returns an authorized provider
    func createOrGetBidder() -> Observable<AuthorizedNetworkingType> {
        return createOrUpdateUser()
            .flatMap { provider -> Observable<AuthorizedNetworkingType> in
                return self.createOrUpdateBidder().mapReplace(provider)
            }
            .flatMap { provider -> Observable<AuthorizedNetworkingType> in
                self.getMyPaddleNumber().mapReplace(provider)
            }
    }
}

private extension BidderNetworkModel {

    // MARK: - Chained observables

    func checkUserEmailExists(email: String) -> Observable<Bool> {
        let request = provider.request(.FindExistingEmailRegistration(email: email))

        return request.map { response in
            return response.statusCode != 404
        }
    }

    func createOrUpdateUser() -> Observable<AuthorizedNetworkingType> {
        // observable to test for user existence (does a user exist with this email?)
        let bool = self.checkUserEmailExists(bidDetails.newUser.email.value ?? "")

        // If the user exists, update their info to the API, otherwise create a new user.
        return bool
            .flatMap { emailExists -> Observable<AuthorizedNetworkingType> in
                if emailExists {
                    return self.updateUser()
                } else {
                    return self.createNewUser()
                }
            }
            .flatMap { provider -> Observable<AuthorizedNetworkingType> in
                self.addCardToUser().mapReplace(provider) // After update/create observable finishes, add a CC to their account (if we've collected one)
            }
    }

    func createNewUser() -> Observable<AuthorizedNetworkingType> {
        let newUser = bidDetails.newUser
        let endpoint: ArtsyAPI = ArtsyAPI.CreateUser(email: newUser.email.value!, password: newUser.password.value!, phone: newUser.phoneNumber.value!, postCode: newUser.zipCode.value ?? "", name: newUser.name.value ?? "")

        return provider.request(endpoint)
            .filterSuccessfulStatusCodes()
            .map(void)
            .doOnError { error in
                logger.log("Creating user failed.")
                logger.log("Error: \((error as NSError).localizedDescription). \n \((error as NSError).artsyServerError())")
        }.flatMap { _ -> Observable<AuthorizedNetworkingType> in
            self.newAuthorizedNetworking()
        }
    }

    func updateUser() -> Observable<AuthorizedNetworkingType> {
        let newUser = bidDetails.newUser
        let endpoint: ArtsyAPI = ArtsyAPI.UpdateMe(email: newUser.email.value!, phone: newUser.phoneNumber.value!, postCode: newUser.zipCode.value ?? "", name: newUser.name.value ?? "")
        return newAuthorizedNetworking()
            .flatMap { (provider) -> Observable<AuthorizedNetworkingType> in
                provider.request(endpoint)
                    .mapJSON()
                    .logNext()
                    .mapReplace(provider)
            }
            .logServerError("Updating user failed.")
    }

    func addCardToUser() -> Observable<Void> {
        // If the user was asked to swipe a card, we'd have stored the token. 
        // If the token is not there, then the user must already have one on file. So we can skip this step.
        guard let token = bidDetails.newUser.creditCardToken.value else {
            return empty()
        }

        let swiped = bidDetails.newUser.swipedCreditCard
        let endpoint: ArtsyAPI = ArtsyAPI.RegisterCard(stripeToken: token, swiped: swiped)

        return provider.request(endpoint)
            .filterSuccessfulStatusCodes()
            .map(void)
            .doOnCompleted { [weak self] in
                // Adding the credit card succeeded, so we shoudl clear the newUser.creditCardToken so that we don't
                // inadvertently try to re-add their card token if they need to increase their bid.

                self?.bidDetails.newUser.creditCardToken.value = nil
            }
            .logServerError("Adding Card to User failed")
    }

    // MARK: - Auction / Bidder observables

    func createOrUpdateBidder() -> Observable<Void> {
        guard let auctionID = bidDetails.saleArtwork?.auctionID else {
            return failWith(EidolonError.CouldNotParseJSON)
        }

        let bool = self.checkForBidderOnAuction(auctionID)

        return bool.flatMap { exists -> Observable<Void> in
            if exists {
                return empty()
            } else {
                return self.registerToAuction(auctionID).then { [weak self] in self?.generateAPIN() }
            }
        }
    }

    func checkForBidderOnAuction(auctionID: String) -> Observable<Bool> {

        let endpoint: ArtsyAPI = ArtsyAPI.MyBiddersForAuction(auctionID: auctionID)
        let request = provider.request(endpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapToObjectArray(Bidder)

        return request.map { [weak self] bidders -> Bool in
            if let bidder = bidders.first {
                self?.bidDetails.bidderID.value = bidder.id
                self?.bidDetails.bidderPIN.value =  bidder.pin

                return true
            }
            return false

        }.logServerError("Getting user bidders failed.")
    }

    func registerToAuction(auctionID: String) -> Observable<Void> {
        let endpoint: ArtsyAPI = ArtsyAPI.RegisterToBid(auctionID: auctionID)
        let register = provider.request(endpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapToObject(Bidder)

        return 
            register.doOnNext{ [weak self] bidder in
                self?.bidDetails.bidderID.value = bidder.id
                self?.bidDetails.newUser.hasBeenRegistered.value = true
            }
            .logServerError("Registering for Auction Failed.")
            .map(void)
    }

    func generateAPIN() -> Observable<Void> {
        let endpoint: ArtsyAPI = ArtsyAPI.CreatePINForBidder(bidderID: bidDetails.bidderID.value!)

        return provider.request(endpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .doOnNext { [weak self] json in
                let pin = json["pin"] as? String
                self?.bidDetails.bidderPIN.value = pin
            }
            .logServerError("Generating a PIN for bidder has failed.")
            .map(void)
    }

    func getMyPaddleNumber() -> Observable<Void> {
        let endpoint: ArtsyAPI = ArtsyAPI.Me
        return provider.request(endpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapToObject(User.self)
            .doOnNext { [weak self] user in
                self?.bidDetails.paddleNumber.value =  user.paddleNumber
            }
            .logServerError("Getting Bidder ID failed.")
            .map(void)
    }

    func newAuthorizedNetworking() -> Observable<AuthorizedNetworkingType> {
        let endpoint: ArtsyAPI = ArtsyAPI.XAuth(email: bidDetails.newUser.email.value!, password: bidDetails.newUser.password.value!)

        return provider.request(endpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .flatMap { accessTokenDict -> Observable<AuthorizedNetworkingType> in
                guard let accessToken = accessTokenDict["access_token"] as? String else {
                    return failWith(EidolonError.CouldNotParseJSON)
                }

                return just(Networking.newAuthorizedNetworking(accessToken))
            }
            .logServerError("Getting Access Token failed.")
    }
}
