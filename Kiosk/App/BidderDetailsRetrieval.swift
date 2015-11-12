import UIKit
import RxSwift
import SVProgressHUD

extension UIViewController {
    func promptForBidderDetailsRetrievalSignal() -> RACSignal {
        return RACSignal.createSignal { (subscriber) -> RACDisposable! in
            let (alertController, command) = UIAlertController.emailPromptAlertController()
            
            subscriber.sendNext(command.executionSignals.switchToLatest())
            self.presentViewController(alertController, animated: true) { }
            
            return nil
        }.map { (emailSignal) -> AnyObject! in
            self.retrieveBidderDetailsSignal(emailSignal as! RACSignal)
        }.switchToLatest()
    }
    
    func retrieveBidderDetailsSignal(emailSignal: RACSignal) -> RACSignal {
        return emailSignal.doNext { _ -> Void in
            SVProgressHUD.show()
        }.map { (email) -> AnyObject! in
            let endpoint: ArtsyAPI = ArtsyAPI.BidderDetailsNotification(auctionID: appDelegate().appViewController.sale.id, identifier: (email as! String))
            
            return XAppRequest(endpoint, provider: Provider.sharedProvider).filterSuccessfulStatusCodes()
        }.switchToLatest().throttle(1).doNext { _ -> Void in
            SVProgressHUD.dismiss()
            self.presentViewController(UIAlertController.successfulBidderDetailsAlertController(), animated: true, completion: nil)
        }.doError { _ -> Void in
            SVProgressHUD.dismiss()
            self.presentViewController(UIAlertController.failedBidderDetailsAlertController(), animated: true, completion: nil)
        }
    }
}

extension UIAlertController {
    class func successfulBidderDetailsAlertController() -> UIAlertController {
        let alertController = self.init(title: "Your details have been sent", message: nil, preferredStyle: .Alert)
        alertController.addAction(RACAlertAction(title: "OK", style: .Default))
        
        return alertController
    }
    
    class func failedBidderDetailsAlertController() -> UIAlertController {
        let alertController = self.init(title: "Incorrect Email", message: "Email was not recognized. You may not be registered to bid yet.", preferredStyle: .Alert)
        alertController.addAction(RACAlertAction(title: "Cancel", style: .Cancel))
        
        let retryAction = RACAlertAction(title: "Retry", style: .Default)
        retryAction.command = appDelegate().requestBidderDetailsCommand()
        
        alertController.addAction(retryAction)
        
        return alertController
    }
    
    class func emailPromptAlertController() -> (UIAlertController, RACCommand) {
        let alertController = self.init(title: "Send Bidder Details", message: "Enter your email address or phone number registered with Artsy and we will send your bidder number and PIN.", preferredStyle: .Alert)

        let ok = RACAlertAction(title: "OK", style: .Default)
        ok.command = RACCommand { (_) -> RACSignal! in
            
            return RACSignal.createSignal { (subscriber) -> RACDisposable! in
                let text = (alertController.textFields?.first)?.text ?? ""
                subscriber.sendNext(text)
                return nil
            }
        }
        let cancel = RACAlertAction(title: "Cancel", style: .Cancel)

        alertController.addTextFieldWithConfigurationHandler(nil)
        alertController.addAction(ok)
        alertController.addAction(cancel)

        return (alertController, ok.command)
    }
}