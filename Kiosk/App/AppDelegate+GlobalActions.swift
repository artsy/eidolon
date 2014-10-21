import UIKit
import QuartzCore

public extension AppDelegate {

    // Registration

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

    // Condtions of Sale and Privacy Policy

    func showConditionsOfSale() {
        self.showWebControllerWithAddress("https://artsy.net/conditions-of-sale")
    }
    
    func showPrivacyPolicy() {
        self.showWebControllerWithAddress("https://artsy.net/privacy")
    }

    
    func showWebControllerWithAddress(address: String) {
        let block = { () -> Void in
            let webController = WebViewController(url: NSURL(string: address)!)
            webController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelPresentedViewController")
            
            let webVC = UINavigationController(rootViewController: webController)
            webVC!.modalPresentationStyle = .FormSheet
            
            self.window.rootViewController?.presentViewController(webVC!, animated: true, completion: nil)
            self.webViewController = webVC
        }

        if helpIsVisisble {
            hideHelp {
                //             Need to give it a second to ensure view heirarchy is good.
                dispatch_async(dispatch_get_main_queue()) {
                    block()
                }
            }
        } else {
            block()
        }
    }

    // Help button and menu

    typealias HelpCompletion = () -> ()

    var helpIsVisisble: Bool {
        return helpViewController != nil
    }

    var webViewControllerIsVisible: Bool {
        return webViewController != nil
    }

    func helpButtonPressed() {
        if helpIsVisisble {
            hideHelp()
        } else {
            showHelp()
        }
    }

    public func cancelPresentedViewController() {
        hidewebViewController()
    }

    func hidewebViewController(completion: (() -> ())? = nil) {
        webViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: completion)
        webViewController = nil
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

    func showHelp(completion: HelpCompletion? = nil) {
        let block = { () -> Void in
            self.setHelpButtonState(.Close)

            let helpViewController = HelpViewController()
            helpViewController.modalPresentationStyle = .Custom
            helpViewController.transitioningDelegate = self

            self.window.rootViewController?.presentViewController(helpViewController, animated: true, completion: {
                self.helpViewController = helpViewController
                completion?()
            })
        }

        if webViewControllerIsVisible {
            hidewebViewController {
                //             Need to give it a second to ensure view heirarchy is good.
                dispatch_async(dispatch_get_main_queue()) {
                    block()
                }
            }
        } else {
            block()
        }
    }

    func hideHelp(completion: HelpCompletion? = nil) {
        setHelpButtonState(.Help)

        helpViewController?.presentingViewController?.dismissViewControllerAnimated(true) {
            self.helpViewController = nil
            completion?()
        }
    }
}

// Help transtion animation

extension AppDelegate: UIViewControllerTransitioningDelegate {
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HelpAnimator(presenting: true)
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HelpAnimator()
    }
}
