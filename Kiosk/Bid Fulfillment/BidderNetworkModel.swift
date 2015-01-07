import UIKit
import ReactiveCocoa
import Moya

public class BidderNetworkModel: NSObject {

    public var bidder:Bidder?
    public var createdNewBidder = false
    public var fulfillmentNav:FulfillmentNavigationController!

    // MARK: - Getters

    private func details() -> BidDetails {
        return fulfillmentNav.bidDetails
    }

    private func provider() -> ReactiveMoyaProvider<ArtsyAPI>  {
        if let provider = fulfillmentNav.loggedInProvider {
            return provider
        }
        return Provider.sharedProvider
    }

    // MARK: - Main Signal

    public func createOrGetBidder() -> RACSignal {
        return createOrUpdateUser().then {
            self.createOrUpdateBidder()

        }.then {
            self.getMyPaddleNumber()
        }
    }

    // MARK: - Chained Signals

    private func checkUserEmailExists(email: String) -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.FindExistingEmailRegistration(email: email)
        let request = Provider.sharedProvider.request(endpoint, method: .HEAD, parameters:endpoint.defaultParameters)

        return request.map { [weak self] (response) -> NSNumber in
            let moyaResponse = response as MoyaResponse
            return moyaResponse.statusCode != 404
        }
    }

    private func createOrUpdateUser() -> RACSignal {
        let boolSignal = self.checkUserEmailExists(details().newUser.email!)
        let signal = RACSignal.`if`(boolSignal, then: self.updateUser(), `else`: self.createNewUser())
        return signal.then { self.addCardToUser() }
    }

    private func createNewUser() -> RACSignal {
        let newUser = details().newUser
        let endpoint: ArtsyAPI = ArtsyAPI.CreateUser(email: newUser.email!, password: newUser.password!, phone: newUser.phoneNumber!, postCode: newUser.zipCode!, name: newUser.name ?? "")

        return Provider.sharedProvider.request(endpoint, method: .POST, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().doError { (error) in
            logger.error("Creating user failed.")
            logger.error("Error: \(error.localizedDescription). \n \(error.artsyServerError())")

        }.then {
            self.updateProvider()
        }
    }

    private func updateUser() -> RACSignal {
        let newUser = details().newUser
        let endpoint: ArtsyAPI = ArtsyAPI.UpdateMe(email: newUser.email!, phone: newUser.phoneNumber!, postCode: newUser.zipCode!, name: newUser.name ?? "")
        let signal = provider().request(endpoint, method: .PUT, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON()

        return signal.doError { (error) in
            logger.error("Updating user failed.")
            logger.error("Error: \(error.localizedDescription). \n \(error.artsyServerError())")
        }
    }

    private func addCardToUser() -> RACSignal {
        if (details().newUser.creditCardToken == nil) { return RACSignal.empty() }
        let endpoint: ArtsyAPI = ArtsyAPI.RegisterCard(balancedToken: details().newUser.creditCardToken!)

        // on Staging the card tokenization fails

        return provider().request(endpoint, method: .POST, parameters: endpoint.defaultParameters).doError { (error) in
            logger.error("Adding Card to User failed.")
            logger.error("Error: \(error.localizedDescription). \n \(error.artsyServerError())")
        }
    }

    // MARK: - Auction / Bidder Signals

    private func createOrUpdateBidder() -> RACSignal {
        let boolSignal = self.checkForBidderOnAuction(self.fulfillmentNav.auctionID)
        let trueSignal = RACSignal.empty()
        let falseSignal = self.registerToAuction().then { self.generateAPIN() }
        return RACSignal.`if`(boolSignal, then: trueSignal, `else`: falseSignal)
    }

    private func checkForBidderOnAuction(auctionID: String) -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.MyBiddersForAuction(auctionID: auctionID)
        let request = provider().request(endpoint, method: .GET, parameters:endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObjectArray(Bidder.self)

        return request.map { [weak self] (bidders) -> NSNumber in
            let bidders = bidders as [Bidder]
            if let bidder = bidders.first {
                self?.details().bidderID = bidder.id
                self?.details().bidderPIN =  bidder.pin
                return true
            }
            return false

        }.doError { (error) in
            logger.error("Getting user bidders failed.")
            logger.error("Error: \(error.localizedDescription). \n \(error.artsyServerError())")
        }
    }

    private func registerToAuction() -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.RegisterToBid(auctionID: fulfillmentNav.auctionID)
        let signal = provider().request(endpoint, method: .POST, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObject(Bidder.self)

        return signal.doNext{ [weak self] (bidder) in
            if let bidder = bidder as? Bidder {
                self?.details().bidderID = bidder.id
                self?.createdNewBidder = true
            }

        } .doError { (error) in
            logger.error("Registering for Auction Failed.")
            logger.error("Error: \(error.localizedDescription). \n \(error.artsyServerError())")
        }
    }

    private func generateAPIN() -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.CreatePINForBidder(bidderID: self.details().bidderID!)

        return provider().request(endpoint, method: .POST, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().doNext { [weak self](json) -> Void in

            let pin = json["pin"] as String?
            self?.details().bidderPIN =  pin

        } .doError { (error) in
            logger.error("Generating a PIN for bidder has failed.")
            logger.error("Error: \(error.localizedDescription). \n \(error.artsyServerError())")
        }
    }

    private func getMyPaddleNumber() -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.Me
        return provider().request(endpoint, method: .GET, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObject(User.self).doNext { [weak self](user) -> Void in

            self?.details().paddleNumber =  (user as User).paddleNumber
            return

        }.doError { (error) in
            logger.error("Getting Bidder ID failed.")
            logger.error("Error: \(error.localizedDescription). \n \(error.artsyServerError())")
        }
    }

    private func updateProvider() -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.XAuth(email: details().newUser.email!, password: details().newUser.password!)

        return provider().request(endpoint, method:.GET, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().doNext { [weak self] (accessTokenDict) -> Void in

            if let accessToken = accessTokenDict["access_token"] as? String {
                self?.fulfillmentNav.xAccessToken = accessToken
            }

        } .doError { (error) in
            logger.error("Getting Access Token failed.")
            logger.error("Error: \(error.localizedDescription). \n \(error.artsyServerError())")
        }
    }
}
