import UIKit

class RegistrationNetworkModel: NSObject {
    
    dynamic var createNewUser = false
    dynamic var details:BidDetails!

    var fulfilmentNav:FulfillmentNavigationController!

    let completedSignal = RACSubject()
    
    func start() {


        var signal = self.createOrUpdateUser().then { [weak self] (_) in
            self?.updateProviderIfNewUser()
        }.then{ [weak self] (_) in
            self?.addCardToUser()
        }.then{ [weak self] (_) in
            self?.registerToAuction()
        }.catchTo(RACSignal.empty())
        
        
        signal.finally {
            println("ok?")
        }.subscribeCompleted { [weak self] (_) in
            self?.completedSignal.sendNext(nil)
            self?.completedSignal.sendCompleted()
        }
//        let sequence = ([createOrUpdateUser(), updateProviderIfNewUser(), addCardToUser(), registerToAuction()] as NSArray).rac_sequence
//        sequence.eagerSequence
        
        
//        RACSignal.merge([createOrUpdateUser(), updateProviderIfNewUser(), addCardToUser(), registerToAuction()]).then { (_) -> RACSignal! in
//            self.completedSignal
//        }.subscribeCompleted { () -> Void in
//            println("hello?");
//        }

    }

    func provider() -> ReactiveMoyaProvider<ArtsyAPI>  {
        if let provider = fulfilmentNav.loggedInProvider {
            return provider
        }
        return Provider.sharedProvider
    }

    func createOrUpdateUser() -> RACSignal {
        let newUser = details.newUser
        if createNewUser {
            
            let endpoint: ArtsyAPI = ArtsyAPI.CreateUser(email: newUser.email!, password: newUser.email!, phone: newUser.phoneNumber!, postCode: newUser.zipCode!)
            return Provider.sharedProvider.request(endpoint, method: .POST, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().doError() { (error) -> Void in
                println("Error creating user: \(error.localizedDescription)")
            }
            
        } else {

            let endpoint: ArtsyAPI = ArtsyAPI.UpdateMe(email: newUser.email!, phone: newUser.email!, postCode: newUser.zipCode!)

            return provider().request(endpoint, method: .PUT).filterSuccessfulStatusCodes().mapJSON().doError() { (error) -> Void in
                println("Error logging in: \(error.localizedDescription)")
            }
        }
    }

    func addCardToUser() -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.RegisterCard(balancedToken: details.newUser.creditCardToken!)

        return provider().request(endpoint, method: .POST).doError() { (error) -> Void in
            println("Error adding card: \(error.localizedDescription)")
        }
    }

    func registerToAuction() -> RACSignal {
        let endpoint: ArtsyAPI = ArtsyAPI.RegisterToBid(auctionID: fulfilmentNav.auctionID)
        return provider().request(endpoint, method: .POST).filterSuccessfulStatusCodes().mapJSON().mapToObject(Bidder.self).doError() { (error) -> Void in
            println("Error registring for auction: \(error.localizedDescription)")
        }
    }

    func updateProviderIfNewUser() -> RACSignal {
        if self.createNewUser {

            let endpoint: ArtsyAPI = ArtsyAPI.XAuth(email: details.newUser.email!, password: details.newUser.password!)

            return provider().request(endpoint, method:.GET, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes().mapJSON().doNext({ [weak self] (accessTokenDict) -> Void in

                if let accessToken = accessTokenDict["access_token"] as? String {
                    self?.fulfilmentNav.xAccessToken = accessToken
                }

            }).doError() { (error) -> Void in
                println("Error logging in: \(error.localizedDescription)")
            }

        } else {
            return RACSignal.empty()
        }
    }
}
