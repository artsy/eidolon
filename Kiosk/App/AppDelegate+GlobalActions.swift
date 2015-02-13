import UIKit
import QuartzCore
import ARAnalytics

func appDelegate() -> AppDelegate {
    return UIApplication.sharedApplication().delegate as AppDelegate
}

public extension AppDelegate {

    // Registration

    func showRegistration() {
        hideHelp {
            // Need to give it a second to ensure view heirarchy is good.
            dispatch_async(dispatch_get_main_queue()) {

                let appVC = self.appViewController
                if let fulfillment = appVC?.presentedViewController as? FulfillmentContainerViewController {
                    fulfillment.closeFulfillmentModal() {
                        return appVC!.registerToBidButtonWasPressed(self)
                    }
                } else {
                    appVC?.registerToBidButtonWasPressed(self)
                }
            }
        }
    }

    var sale: Sale! {
        return appViewController!.sale
    }

    internal var appViewController: AppViewController? {
        let nav = self.window.rootViewController?.findChildViewControllerOfType(UINavigationController) as? UINavigationController
        return nav?.delegate as? AppViewController
    }

    // Condtions of Sale and Privacy Policy

    func showConditionsOfSale() {
        showWebControllerWithAddress("https://artsy.net/conditions-of-sale")
    }
    
    func showPrivacyPolicy() {
        showWebControllerWithAddress("https://artsy.net/privacy")
    }

    func showBuyersPremium() {
        let saleID = sale.id
        showWebControllerWithAddress("https://m.artsy.net/auction/\(saleID)/buyers-premium")
    }
    
    func showWebControllerWithAddress(address: String) {
        let block = { () -> Void in
            let webController = ModalWebViewController(url: NSURL(string: address)!)

            let nav = UINavigationController(rootViewController: webController)
            nav.modalPresentationStyle = .FormSheet
            
            ARAnalytics.event("Show Web View", withProperties: ["url" : address])
            self.window.rootViewController?.presentViewController(nav, animated: true, completion: nil)

            self.webViewController = nav
        }

        if helpIsVisisble {
            hideHelp {
                // Need to give it a second to ensure view heirarchy is good.
                dispatch_async(dispatch_get_main_queue()) {
                    block()
                }
            }
        } else if fulfillmentViewControllerIsVisisble {
            hideFulfillmentViewConroller {
                // Need to give it a second to ensure view heirarchy is good.
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

    var fulfillmentViewControllerIsVisisble: Bool {
        return appViewController?.presentedViewController != nil
    }

    func helpButtonPressed() {
        if helpIsVisisble {
            hideHelp()
        } else {
            showHelp()
        }
    }

    func hideFulfillmentViewConroller(completion: (() -> ())? = nil) {
        appViewController?.dismissViewControllerAnimated(true, completion: completion)
    }

    func hidewebViewController(completion: (() -> ())? = nil) {
        webViewController?.presentingViewController?.dismissViewControllerAnimated(true, completion: completion)
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
                // Need to give it a second to ensure view heirarchy is good.
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
            completion?()
            return
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
