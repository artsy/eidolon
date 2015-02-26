import UIKit
import ReactiveCocoa
import RACAlertAction

public extension UIViewController {
    func promptForBidderDetailsRetrievalSignal() -> RACSignal {
        return RACSignal.createSignal { (subscriber) -> RACDisposable! in
            let (alertControler, command) = UIAlertController.emailPromptAlertController()
            
            subscriber.sendNext(command.executionSignals.switchToLatest())
            self.presentViewController(alertControler, animated: true) { }
            
            return nil
        }.map { (emailSignal) -> AnyObject! in
            self.retrieveBidderDetailsSignal(emailSignal as RACSignal)
        }.switchToLatest()
    }
    
    func retrieveBidderDetailsSignal(emailSignal: RACSignal) -> RACSignal {
        return emailSignal.doNext { (thing) -> Void in
            // TODO: Show spinner for user
            println("Got1: \(thing)")
        }.map { (email) -> AnyObject! in
            let endpoint: ArtsyAPI = ArtsyAPI.BidderDetailsNotification(auctionID: appDelegate().appViewController.sale.id, identifier: (email as String))
            
            return XAppRequest(endpoint, provider: Provider.sharedProvider, method: .PUT, parameters: endpoint.defaultParameters).filterSuccessfulStatusCodes()
        }.switchToLatest().doCompleted { _ -> Void in
            self.presentViewController(UIAlertController.successfulBidderDetailsAlertController(), animated: true, completion: nil)
        }.doError { _ -> Void in
            self.presentViewController(UIAlertController.failedBidderDetailsAlertController(), animated: true, completion: nil)
        }
    }
}

extension UIAlertController {
    class func successfulBidderDetailsAlertController() -> UIAlertController {
        let alertController = self(title: "Your details have been sent", message: nil, preferredStyle: .Alert)
        alertController.addAction(RACAlertAction(title: "OK", style: .Default))
        
        return alertController
    }
    
    class func failedBidderDetailsAlertController() -> UIAlertController {
        let alertController = self(title: "Incorrect Email", message: "Enter your email address registered with Artsy and we will send your bidder number and PIN.", preferredStyle: .Alert)
        alertController.addAction(RACAlertAction(title: "OK", style: .Default))
        
        return alertController
    }
    
    class func emailPromptAlertController() -> (UIAlertController, RACCommand) {
        let alertController = self(title: "Send Bidder Details", message: "Enter your email address registered with Artsy and we will send your bidder number and PIN.", preferredStyle: .Alert)

        let ok = RACAlertAction(title: "OK", style: .Default)
        ok.rac_command = RACCommand { (_) -> RACSignal! in
            
            return RACSignal.createSignal { (subscriber) -> RACDisposable! in
                let text = (alertController.textFields?.first as? UITextField)?.text ?? ""
                subscriber.sendNext(text)
                return nil
            }
        }
        let cancel = RACAlertAction(title: "Cancel", style: .Cancel)

        alertController.addTextFieldWithConfigurationHandler(nil)
        alertController.addAction(ok)
        alertController.addAction(cancel)

        return (alertController, ok.rac_command)
    }
}