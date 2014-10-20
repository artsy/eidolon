import UIKit

class RegistrationNetworkModel: NSObject {
    
    dynamic var createNewUser = false
    dynamic var details:BidDetails!
    var bidder:Bidder?

    var fulfillmentNav:FulfillmentNavigationController!

    func registerSignal() -> RACSignal {

        return self.checkForEmailExistence(details.newUser.email!).then {
            self.createOrUpdateUser()

        }.then {
            self.addCardToUser()

        }.then {
            self.checkForBidderOnAuction(self.fulfillmentNav.auctionID)

        }.then {
            self.bidder == nil ? self.registerToAuction() : RACSignal.empty()

        }.then {
            self.generateAPIN()

        }.then {
            self.getMyPaddleNumber()
        }
    }

    func provider() -> ReactiveMoyaProvider<ArtsyAPI>  {
        if let provider = fulfillmentNav.loggedInProvider {
            return provider
        }
        return Provider.sharedProvider
    }

    func checkForEmailExistence(email: String) -> RACSignal {

        let endpoint: ArtsyAPI = ArtsyAPI.FindExistingEmailRegistration(email: email)
        let request = Provider.sharedProvider.request(endpoint, method: .HEAD, parameters:endpoint.defaultParameters)

        return request.doNext { [weak self] (response) -> Void in
            let moyaResponse = response as MoyaResponse
            self?.createNewUser = moyaResponse.statusCode == 404
        }
    }

    func checkForBidderOnAuction(auctionID: String) -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.MyBiddersForAuction(auctionID: auctionID)
        let request = provider().request(endpoint, method: .GET, parameters:endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObjectArray(Bidder.self)

        return request.doNext { [weak self] (bidders) -> Void in
            let bidders = bidders as [Bidder]
            self?.bidder = bidders.first

        }.doError { (error) in
            log.error("Getting user bidders failed.")
            log.error("Error: \(error.localizedDescription).")
        }
    }


    func createOrUpdateUser() -> RACSignal {
        let newUser = details.newUser
        if createNewUser {
            
            let endpoint: ArtsyAPI = ArtsyAPI.CreateUser(email: newUser.email!, password: newUser.password!, phone: newUser.phoneNumber!, postCode: newUser.zipCode!)

            return Provider.sharedProvider.request(endpoint, method: .POST, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().doError { (error) in
                log.error("Creating user failed.")
                log.error("Error: \(error.localizedDescription).")

            }.then { self.updateProvider() }
            
        } else {
            let endpoint: ArtsyAPI = ArtsyAPI.UpdateMe(email: newUser.email!, phone: newUser.phoneNumber!, postCode: newUser.zipCode!)

            return provider().request(endpoint, method: .PUT, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().doError { (error) in
                log.error("Updating user bidders failed.")
                log.error("Error: \(error.localizedDescription).")
            }
        }
    }

    func addCardToUser() -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.RegisterCard(balancedToken: details.newUser.creditCardToken!)

        // on Staging the card tokenization fails

        return provider().request(endpoint, method: .POST, parameters: endpoint.defaultParameters).doError { (error) in
            log.error("Adding Card to User failed.")
            log.error("Error: \(error.localizedDescription).")
        }
    }

    func registerToAuction() -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.RegisterToBid(auctionID: fulfillmentNav.auctionID)
        return provider().request(endpoint, method: .POST, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObject(Bidder.self).doNext({ [weak self](bidder) -> Void in

            self?.fulfillmentNav.bidDetails.bidderID = (bidder as Bidder).id
            return

        }).doError { (error) in
            log.error("Registering for Auction Failed.")
            log.error("Error: \(error.localizedDescription).")
        }
    }

    func generateAPIN() -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.CreatePINForBidder(bidderNumber: fulfillmentNav.bidDetails.bidderID!)

        return provider().request(endpoint, method: .POST, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().doNext({ [weak self](json) -> Void in
            
            if let pin = json["pin"] as? String {
                self?.fulfillmentNav.bidDetails.bidderPIN =  pin
            }
                
        }).doError { (error) in
            log.error("Generating a PIN for bidder has failed.")
            log.error("Error: \(error.localizedDescription).")
        }
    }

    func getMyPaddleNumber() -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.Me
        return provider().request(endpoint, method: .GET, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().mapToObject(User.self).doNext { [weak self](user) -> Void in

            self?.fulfillmentNav.bidDetails.bidderNumber =  (user as User).paddleNumber
            return

        }.doError { (error) in
            log.error("Getting Bidder ID failed.")
            log.error("Error: \(error.localizedDescription).")
        }
    }


    func updateProvider() -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.XAuth(email: details.newUser.email!, password: details.newUser.password!)

        return provider().request(endpoint, method:.GET, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().doNext { [weak self] (accessTokenDict) -> Void in

            if let accessToken = accessTokenDict["access_token"] as? String {
                self?.fulfillmentNav.xAccessToken = accessToken
            }

        }.doError { (error) in
            log.error("Getting Access Token failed.")
            log.error("Error: \(error.localizedDescription).")
        }
    }
}
