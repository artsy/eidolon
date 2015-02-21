import UIKit
import QuartzCore
import ARAnalytics
import ReactiveCocoa
import Swift_RAC_Macros

func appDelegate() -> AppDelegate {
    return UIApplication.sharedApplication().delegate as AppDelegate
}

public extension AppDelegate {

    // Registration

    var sale: Sale! {
        return appViewController!.sale
    }

    internal var appViewController: AppViewController! {
        let nav = self.window.rootViewController?.findChildViewControllerOfType(UINavigationController) as? UINavigationController
        return nav?.delegate as? AppViewController
    }

    // Help button and menu

    func setupHelpButton() {
        helpButton = MenuButton()
        helpButton.setTitle("Help", forState: .Normal)
        helpButton.rac_command = helpButtonCommand()
        window.addSubview(helpButton)
        helpButton.alignTop(nil, leading: nil, bottom: "-24", trailing: "-24", toView: window)
        window.layoutIfNeeded()

        RACObserve(self, "helpViewController").notNil().subscribeNext {
            let isVisible = $0 as Bool

            var image: UIImage? = isVisible ?  UIImage(named: "xbtn_white")?.imageWithRenderingMode(.AlwaysOriginal) : nil
            var text: String? = isVisible ? nil : "HELP"

            self.helpButton.setTitle(text, forState: .Normal)
            self.helpButton.setImage(image, forState: .Normal)

            let transition = CATransition()
            transition.duration = AnimationDuration.Normal
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionFade
            self.helpButton.layer.addAnimation(transition, forKey: "fade")
        }
    }

    func setHelpButtonHidden(hidden: Bool) {
        helpButton.hidden = hidden
    }
}

// MARK: - ReactiveCocoa extensions

extension AppDelegate {
    // In this extension, I'm omitting [weak self] because the app delegate will outlive everyone.

    func showBuyersPremiumCommand(enabledSignal: RACSignal? = nil) -> RACCommand {
        return RACCommand(enabled: enabledSignal) { _ -> RACSignal! in
            self.hideAllTheThingsSignal().then {
                self.showWebControllerSignal("https://m.artsy.net/auction/\(self.sale.id)/buyers-premium")
            }
        }
    }

    func registerToBidCommand(enabledSignal: RACSignal? = nil) -> RACCommand {
        return RACCommand(enabled: enabledSignal) { _ -> RACSignal! in
            self.hideAllTheThingsSignal().then {
                self.showRegistrationSignal()
            }
        }
    }

    func requestBidderDetailsCommand(enabledSignal: RACSignal? = nil) -> RACCommand {
        return RACCommand(enabled: enabledSignal) { _ -> RACSignal! in
            RACSignal.empty().then {
                self.hideHelpSignal()
            }.then {
                return RACSignal.createSignal { _ -> RACDisposable! in
                    let appVC = self.appViewController
                    if let presentingVIewController = appVC?.presentedViewController ?? appVC {
                        // TODO: This should be a signal and stuff
                        presentingVIewController.promptForBidderDetailsRetrieval()
                    }

                    return nil
                }
            }
        }
    }

    func helpButtonCommand() -> RACCommand {
        return RACCommand() { _ -> RACSignal! in
            RACSignal.`if`(self.helpIsVisisbleSignal.take(1), then: self.hideHelpSignal(), `else`: self.showHelpSignal())
        }
    }

    func showPrivacyPolicyCommand() -> RACCommand {
        return RACCommand() { _ -> RACSignal! in
            self.hideAllTheThingsSignal().then { self.showWebControllerSignal("https://artsy.net/privacy") }
        }
    }

    func showConditionsOfSaleCommand() -> RACCommand {
        return RACCommand() { _ -> RACSignal! in
            self.hideAllTheThingsSignal().then { self.showWebControllerSignal("https://artsy.net/conditions-of-sale") }
        }
    }
}

// MARK: - Private ReactiveCocoa Extension

private extension AppDelegate {

    // MARK: - Signals that do things

    func hideAllTheThingsSignal() -> RACSignal {
        return RACSignal.empty().then {
            self.closeFulfillmentViewControllerSignal()
        }.then {
            self.hideHelpSignal()
        }
    }

    func showRegistrationSignal() -> RACSignal {
        return RACSignal.createSignal { (subscriber) -> RACDisposable! in
            ARAnalytics.event("Register To Bid Tapped")

            let storyboard = UIStoryboard.fulfillment()
            let containerController = storyboard.instantiateInitialViewController() as FulfillmentContainerViewController
            containerController.allowAnimations = self.appViewController.allowAnimations

            if let internalNav: FulfillmentNavigationController = containerController.internalNavigationController() {
                let registerVC = storyboard.viewControllerWithID(.RegisterAnAccount) as RegisterViewController
                registerVC.placingBid = false
                internalNav.auctionID = self.appViewController.auctionID
                internalNav.viewControllers = [registerVC]
            }

            self.appViewController.presentViewController(containerController, animated: false) {
                containerController.viewDidAppearAnimation(containerController.allowAnimations)

                sendDispatchCompleted(subscriber)
            }

            return nil
        }
    }

    func showHelpSignal() -> RACSignal {
        return RACSignal.createSignal { (subscriber) -> RACDisposable! in
            let helpViewController = HelpViewController()
            helpViewController.modalPresentationStyle = .Custom
            helpViewController.transitioningDelegate = self

            self.window.rootViewController?.presentViewController(helpViewController, animated: true, completion: {
                self.helpViewController = helpViewController
                sendDispatchCompleted(subscriber)
            })

            return nil
        }
    }

    // TODO: Correct animation?
    func closeFulfillmentViewControllerSignal() -> RACSignal {
        let closeSignal = RACSignal.createSignal { (subscriber) -> RACDisposable! in
            (self.appViewController.presentedViewController as? FulfillmentContainerViewController)?.closeFulfillmentModal() {
                sendDispatchCompleted(subscriber)
            }

            return nil
        }

        return RACSignal.`if`(fullfilmentVisibleSignal, then: closeSignal, `else`: RACSignal.empty())
    }

    func showWebControllerSignal(address: String) -> RACSignal {
        return hideWebViewControllerSignal().then {
            RACSignal.createSignal { (subscriber) -> RACDisposable! in
                let webController = ModalWebViewController(url: NSURL(string: address)!)

                let nav = UINavigationController(rootViewController: webController)
                nav.modalPresentationStyle = .FormSheet

                ARAnalytics.event("Show Web View", withProperties: ["url" : address])
                self.window.rootViewController?.presentViewController(nav, animated: true) {
                    sendDispatchCompleted(subscriber)
                }

                self.webViewController = nav

                return nil
            }
        }
    }

    func hideHelpSignal() -> RACSignal {
        return RACSignal.createSignal { (subscriber) -> RACDisposable! in
            if let presentingViewController = self.helpViewController?.presentingViewController? {
                presentingViewController.dismissViewControllerAnimated(true) {
                    sendDispatchCompleted(subscriber)
                }
            } else {
                subscriber.sendCompleted()
            }


            return nil
        }
    }

    func hideWebViewControllerSignal() -> RACSignal {
        return RACSignal.createSignal { (subscriber) -> RACDisposable! in
            if let webViewController = self.webViewController {
                webViewController.presentingViewController?.dismissViewControllerAnimated(true) { () -> Void in
                    sendDispatchCompleted(subscriber)
                }
            } else {
                subscriber.sendCompleted()
            }

            return nil
        }
    }

    // MARK: - Computed property signals

    var fullfilmentVisibleSignal: RACSignal {
        return RACSignal.defer {
            return RACSignal.createSignal { (subscriber) -> RACDisposable! in
                subscriber.sendNext((self.appViewController.presentedViewController as? FulfillmentContainerViewController) != nil)
                subscriber.sendCompleted()

                return nil
            }
        }
    }

    var helpIsVisisbleSignal: RACSignal {
        return RACObserve(self, "helpViewController").notNil()
    }
}

// MARK: - Help transtion animation

extension AppDelegate: UIViewControllerTransitioningDelegate {
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HelpAnimator(presenting: true)
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HelpAnimator()
    }
}
