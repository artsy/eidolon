import UIKit
import RxSwift
import SVProgressHUD
import Action

extension UIViewController {
    func promptForBidderDetailsRetrievalSignal() -> Observable<Void> {
        return deferred { () -> Observable<Bool> in
            let (alertController, command) = UIAlertController.emailPromptAlertController()

            self.presentViewController(alertController, animated: true) { }
            
            return command.executing
            // TODO: We need to send String over the action, but it can only accept Void :(
        }.flatMap { emailSignal -> Observable<Void> in
//            self.retrieveBidderDetailsSignal(emailSignal)
            return empty()
        }
    }
    
    func retrieveBidderDetailsSignal(emailSignal: Observable<String>) -> Observable<Void> {
        return emailSignal
            .take(1)
            .doOnNext { _ in
                SVProgressHUD.show()
            }
            .flatMap { email -> Observable<Void> in
                let endpoint = ArtsyAPI.BidderDetailsNotification(auctionID: appDelegate().appViewController.sale.value.id, identifier: email)

                return XAppRequest(endpoint, provider: Provider.sharedProvider).filterSuccessfulStatusCodes().map(void)
            }
            .throttle(1, MainScheduler.sharedInstance)
            .doOnNext { _ -> Void in
                SVProgressHUD.dismiss()
                self.presentViewController(UIAlertController.successfulBidderDetailsAlertController(), animated: true, completion: nil)
            }
            .doOnError { _ -> Void in
                SVProgressHUD.dismiss()
                self.presentViewController(UIAlertController.failedBidderDetailsAlertController(), animated: true, completion: nil)
            }
    }
}

extension UIAlertController {
    class func successfulBidderDetailsAlertController() -> UIAlertController {
        let alertController = self.init(title: "Your details have been sent", message: nil, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction.Action("OK", style: .Default))
        
        return alertController
    }
    
    class func failedBidderDetailsAlertController() -> UIAlertController {
        let alertController = self.init(title: "Incorrect Email", message: "Email was not recognized. You may not be registered to bid yet.", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction.Action("Cancel", style: .Cancel))
        
        let retryAction = UIAlertAction.Action("Retry", style: .Default)
        retryAction.rx_action = appDelegate().requestBidderDetailsCommand()
        
        alertController.addAction(retryAction)
        
        return alertController
    }
    
    class func emailPromptAlertController() -> (UIAlertController, CocoaAction) {
        let alertController = self.init(title: "Send Bidder Details", message: "Enter your email address or phone number registered with Artsy and we will send your bidder number and PIN.", preferredStyle: .Alert)

        let ok = UIAlertAction.Action("OK", style: .Default)
        let action = CocoaAction { _ -> Observable<Void> in
            
            return create { observer -> Disposable in
                observer.onNext()
                return NopDisposable.instance
            }
        }
        ok.rx_action = action
        let cancel = UIAlertAction.Action("Cancel", style: .Cancel)

        alertController.addTextFieldWithConfigurationHandler(nil)
        alertController.addAction(ok)
        alertController.addAction(cancel)

        return (alertController, action)
    }
}