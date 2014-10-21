import UIKit
import QuartzCore

public extension AppDelegate {
    typealias HelpCompletion = () -> ()
    
    var helpIsVisisble: Bool {
        return helpViewController != nil
    }
    
    var helpPresentedViewControllerIsVisible: Bool {
        return helpPresentedViewController != nil
    }
    
    func setupHelpButton() {
        helpButton = MenuButton()
        helpButton.setTitle("Help", forState: .Normal)
        helpButton.addTarget(self, action: "helpButtonPressed", forControlEvents: .TouchUpInside)
        window.addSubview(helpButton)
        helpButton.alignTop(nil, leading: nil, bottom: "-24", trailing: "-24", toView: window)
        window.layoutIfNeeded()
    }
    
    enum HelpButtonState {
        case Help
        case Close
    }
    
    func setHelpButtonState(state: HelpButtonState) {
        var image: UIImage? = nil
        var text: String? = nil
        
        switch state {
        case .Help:
            text = "HELP"
        case .Close:
            image = UIImage(named: "xbtn_white")?.imageWithRenderingMode(.AlwaysOriginal)
        }
        
        helpButton.setTitle(text, forState: .Normal)
        helpButton.setImage(image, forState: .Normal)
        
        let transition = CATransition()
        transition.duration = AnimationDuration.Normal
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        helpButton.layer.addAnimation(transition, forKey: "fade")
    }

    func setHelpButtonHidden(hidden: Bool) {
        helpButton.hidden = hidden
    }

    func showHelp(completion: HelpCompletion? = nil) {
        setHelpButtonState(.Close)
        
        let helpViewController = HelpViewController()
        helpViewController.modalPresentationStyle = .Custom
        helpViewController.transitioningDelegate = self
        
        let controller = window.rootViewController?.presentedViewController ?? window.rootViewController
        controller?.presentViewController(helpViewController, animated: true, completion: {
            self.helpViewController = helpViewController
            completion?()
        })
    }
    
    func hideHelp(completion: HelpCompletion? = nil) {
        setHelpButtonState(.Help)
        
        helpViewController?.presentingViewController?.dismissViewControllerAnimated(true) {
            self.helpViewController = nil
            completion?()
        }
    }
    
    func helpButtonPressed() {
        if helpIsVisisble {
            hideHelp()
        } else {
            if helpPresentedViewControllerIsVisible {
                hidePresentedViewController({
                    self.showHelp()
                })
            } else {
                showHelp()
            }
        }
    }
    
    func showRegistration() {
        hideHelp {
            // Need to give it a second to ensure view heirarchy is good.
            dispatch_async(dispatch_get_main_queue()) {
                let listingsVCNav = self.window.rootViewController?.childViewControllers.first! as UINavigationController
                let listingVC = listingsVCNav.topViewController as ListingsViewController
                listingVC.registerTapped(self)
            }
        }
    }
    
    func showConditionsOfSale() {
        hideHelp {
            // Need to give it a second to ensure view heirarchy is good.
            dispatch_async(dispatch_get_main_queue()) {
                self.showWebControllerWithAddress("https://artsy.net/conditions-of-sale")
            }
        }
    }
    
    func showPrivacyPolicy() {
        hideHelp {
            // Need to give it a second to ensure view heirarchy is good.
            dispatch_async(dispatch_get_main_queue()) {
                self.showWebControllerWithAddress("https://artsy.net/privacy")
            }
        }
    }
    
    public func cancelPresentedViewController() {
        hidePresentedViewController()
    }
    
    func hidePresentedViewController(completion: (() -> ())? = nil) {
        helpPresentedViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: completion)
        helpPresentedViewController = nil
    }
    
    func showWebControllerWithAddress(address: String) {
        let webController = WebViewController.instantiateFromStoryboard(NSURL(string: address)!)
        webController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelPresentedViewController")
        
        helpPresentedViewController = UINavigationController(rootViewController: webController)
        helpPresentedViewController!.modalPresentationStyle = .PageSheet
        
        window.rootViewController?.presentViewController(self.helpPresentedViewController!, animated: true, completion: nil)
    }
}

extension AppDelegate: UIViewControllerTransitioningDelegate {
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HelpAnimator(presenting: true)
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HelpAnimator()
    }
}
