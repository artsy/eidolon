import UIKit
import QuartzCore

extension AppDelegate {
    typealias HelpCompletion = () -> ()
    
    var helpIsVisisble: Bool {
        return helpViewController != nil
    }
    
    func setupHelpButton() {
        helpButton = MenuButton()
        helpButton.setTitle("Help", forState: .Normal)
        helpButton.addTarget(self, action: "helpButtonPressed", forControlEvents: .TouchUpInside)
        window.addSubview(helpButton)
        helpButton.alignTop(nil, leading: nil, bottom: "-45", trailing: "-45", toView: window)
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
            showHelp()
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
            
        }
    }
}

extension AppDelegate: UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HelpAnimator(presenting: true)
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HelpAnimator()
    }
}