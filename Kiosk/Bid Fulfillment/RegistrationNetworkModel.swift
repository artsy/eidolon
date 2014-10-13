import UIKit

class RegistrationNetworkModel: NSObject {
    
    dynamic var createNewUser = false
    dynamic var details:BidDetails!
    var provider:ReactiveMoyaProvider<ArtsyAPI>!
    
    let completedSignal = RACSubject()
    
    func start() {
        var signal = RACSignal.empty()
        signal = signal.then { [weak self] (_) in
            
            self?.createOrUpdateUser()
            
        }.then { [weak self] (_) in
            println("third")
            return RACSignal.empty()
        }
        
        signal.subscribeCompleted { (_) in
            println("SHOULD BE DONE")
        }
    }

    func createOrUpdateUser() -> RACSignal {
        let newUser = details.newUser
        if createNewUser {
            
            let endpoint: ArtsyAPI = ArtsyAPI.UpdateMe(email: newUser.email!, phone: newUser.email!, postCode: newUser.zipCode!)
            return XAppRequest(endpoint, provider: provider, method: .PUT, parameters: Moya.DefaultParameters(), defaults: NSUserDefaults.standardUserDefaults())
            
        } else {

            let endpoint: ArtsyAPI = ArtsyAPI.UpdateMe(email: newUser.email!, phone: newUser.email!, postCode: newUser.zipCode!)
            return provider.request(endpoint, method: .PUT)
        }
    }
}
