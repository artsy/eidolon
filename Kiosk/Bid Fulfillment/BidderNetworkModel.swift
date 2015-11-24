import Foundation
import RxSwift
import Moya

class BidderNetworkModel: NSObject {
    // MARK: - Getters

    unowned let fulfillmentController: FulfillmentController

    var createdNewUser: Observable<Bool> {
        return self.fulfillmentController.bidDetails.newUser.hasBeenRegistered.asObservable()
    }

    init(fulfillmentController: FulfillmentController) {
        self.fulfillmentController = fulfillmentController
    }

    // MARK: - Main Signal

    func createOrGetBidder() -> Observable<User> {
        return createOrUpdateUser().then { [weak self] in
            self?.createOrUpdateBidder()

        }.andThen { [weak self] in
            self?.getMyPaddleNumber()
        }
    }

    // MARK: - Chained Signals

    private func checkUserEmailExists(email: String) -> Observable<Bool> {
        let request = Provider.sharedProvider.request(.FindExistingEmailRegistration(email: email))

        return request.map { response in
            return response.statusCode != 404
        }
    }

    private func createOrUpdateUser() -> Observable<Void> {
        // Signal to test for user existence (does a user exist with this email?)
        let boolSignal = self.checkUserEmailExists(fulfillmentController.bidDetails.newUser.email.value ?? "")

        // If the user exists, update their info to the API, otherwise create a new user.
        return boolSignal.flatMap { emailExists in
                if emailExists {
                    return self.updateUser()
                } else {
                    return self.createNewUser()
                }
            }
            .then (self.addCardToUser()) // After update/create signal finishes, add a CC to their account (if we've collected one)


    }

    private func createNewUser() -> Observable<Void> {
        let newUser = fulfillmentController.bidDetails.newUser
        let endpoint: ArtsyAPI = ArtsyAPI.CreateUser(email: newUser.email.value!, password: newUser.password.value!, phone: newUser.phoneNumber.value!, postCode: newUser.zipCode.value ?? "", name: newUser.name.value ?? "")

        return Provider.sharedProvider
            .request(endpoint)
            .filterSuccessfulStatusCodes()
            .map(void)
            .doOnError { error in
                logger.log("Creating user failed.")
                logger.log("Error: \((error as NSError).localizedDescription). \n \((error as NSError).artsyServerError())")
        }.then { [weak self] in
            self?.updateProvider()
        }
    }

    private func updateProviderIfNecessary() -> Observable<Void> {
        if fulfillmentController.loggedInProvider.hasValue {
            return empty()
        } else {
            return updateProvider()
        }
    }

    private func updateUser() -> Observable<Void> {
        let newUser = fulfillmentController.bidDetails.newUser
        let endpoint: ArtsyAPI = ArtsyAPI.UpdateMe(email: newUser.email.value!, phone: newUser.phoneNumber.value!, postCode: newUser.zipCode.value ?? "", name: newUser.name.value ?? "")
        return updateProviderIfNecessary()
            .then { [weak self] in
                self?.fulfillmentController
                    .loggedInProvider!
                    .request(endpoint)
                    .filterSuccessfulStatusCodes()
                    .mapJSON()
                    .logNext()
                    .map(void)
            }
            .logServerError("Updating user failed.")
    }

    private func addCardToUser() -> Observable<Void> {
        // If the user was asked to swipe a card, we'd have stored the token. 
        // If the token is not there, then the user must already have one on file. So we can skip this step.
        guard let token = fulfillmentController.bidDetails.newUser.creditCardToken.value else {
            return empty()
        }

        let swiped = fulfillmentController.bidDetails.newUser.swipedCreditCard
        let endpoint: ArtsyAPI = ArtsyAPI.RegisterCard(stripeToken: token, swiped: swiped)

        return fulfillmentController
            .loggedInProvider!
            .request(endpoint)
            .filterSuccessfulStatusCodes()
            .map(void)
            .doOnCompleted { [weak self] in
                // Adding the credit card succeeded, so we shoudl clear the newUser.creditCardToken so that we don't
                // inadvertently try to re-add their card token if they need to increase their bid.

                self?.fulfillmentController.bidDetails.newUser.creditCardToken.value = nil
            }
            .logServerError("Adding Card to User failed")
    }

    // MARK: - Auction / Bidder Signals

    private func createOrUpdateBidder() -> Observable<Void> {
        let boolSignal = self.checkForBidderOnAuction(self.fulfillmentController.auctionID)


        return boolSignal.flatMap { exists -> Observable<Void> in
            if exists {
                return empty()
            } else {
                return self.registerToAuction().then { [weak self] in self?.generateAPIN() }
            }
        }
    }

    private func checkForBidderOnAuction(auctionID: String) -> Observable<Bool> {
        let endpoint: ArtsyAPI = ArtsyAPI.MyBiddersForAuction(auctionID: auctionID)
        let request = fulfillmentController
            .loggedInProvider!
            .request(endpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapToObjectArray(Bidder)

        return request.map { [weak self] bidders -> Bool in
            if let bidder = bidders.first {
                self?.fulfillmentController.bidDetails.bidderID.value = bidder.id
                self?.fulfillmentController.bidDetails.bidderPIN.value =  bidder.pin

                return true
            }
            return false

        }.logServerError("Getting user bidders failed.")
    }

    private func registerToAuction() -> Observable<Void> {
        let endpoint: ArtsyAPI = ArtsyAPI.RegisterToBid(auctionID: fulfillmentController.auctionID)
        let signal = fulfillmentController
            .loggedInProvider!
            .request(endpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapToObject(Bidder)

        return signal
            .doOnNext{ [weak self] bidder in
                self?.fulfillmentController.bidDetails.bidderID.value = bidder.id
                self?.fulfillmentController.bidDetails.newUser.hasBeenRegistered.value = true
            }
            .logServerError("Registering for Auction Failed.")
            .map(void)
    }

    private func generateAPIN() -> Observable<Void> {
        let endpoint: ArtsyAPI = ArtsyAPI.CreatePINForBidder(bidderID: fulfillmentController.bidDetails.bidderID.value!)

        return fulfillmentController
            .loggedInProvider!
            .request(endpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .doOnNext { [weak self] json in
                let pin = json["pin"] as? String
                self?.fulfillmentController.bidDetails.bidderPIN.value = pin
            }
            .logServerError("Generating a PIN for bidder has failed.")
            .map(void)
    }

    private func getMyPaddleNumber() -> Observable<Void> {
        let endpoint: ArtsyAPI = ArtsyAPI.Me
        return fulfillmentController
            .loggedInProvider!
            .request(endpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .mapToObject(User.self)
            .doOnNext { [weak self] user in
                self?.fulfillmentController.bidDetails.paddleNumber.value =  user.paddleNumber
            }
            .logServerError("Getting Bidder ID failed.")
            .map(void)
    }

    private func updateProvider() -> Observable<Void> {
        let endpoint: ArtsyAPI = ArtsyAPI.XAuth(email: fulfillmentController.bidDetails.newUser.email.value!, password: fulfillmentController.bidDetails.newUser.password.value!)

        return fulfillmentController
            .loggedInOrDefaultProvider
            .request(endpoint)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .doOnNext { [weak self] accessTokenDict in
                if let accessToken = accessTokenDict["access_token"] as? String {
                    self?.fulfillmentController.xAccessToken = accessToken
                }
            }
            .logServerError("Getting Access Token failed.")
            .map(void)
    }
}
