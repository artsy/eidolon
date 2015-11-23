import UIKit
import QuartzCore
import ARAnalytics
import RxSwift
import Action

func appDelegate() -> AppDelegate {
    return UIApplication.sharedApplication().delegate as! AppDelegate
}

extension AppDelegate {

    // Registration

    var sale: Sale! {
        return appViewController!.sale
    }

    internal var appViewController: AppViewController! {
        let nav = self.window?.rootViewController?.findChildViewControllerOfType(UINavigationController) as? UINavigationController
        return nav?.delegate as? AppViewController
    }

    // Help button and menu

    func setupHelpButton() {
        helpButton = MenuButton()
        helpButton.setTitle("Help", forState: .Normal)
        helpButton.rx_action = helpButtonCommand()
        window?.addSubview(helpButton)
        helpButton.alignTop(nil, leading: nil, bottom: "-24", trailing: "-24", toView: window)
        window?.layoutIfNeeded()

        helpIsVisisbleSignal.subscribeNext { visisble in
            let image: UIImage? = visisble ?  UIImage(named: "xbtn_white")?.imageWithRenderingMode(.AlwaysOriginal) : nil
            let text: String? = visisble ? nil : "HELP"

            self.helpButton.setTitle(text, forState: .Normal)
            self.helpButton.setImage(image, forState: .Normal)

            let transition = CATransition()
            transition.duration = AnimationDuration.Normal
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionFade
            self.helpButton.layer.addAnimation(transition, forKey: "fade")

        }.addDisposableTo(rx_disposeBag)
    }

    func setHelpButtonHidden(hidden: Bool) {
        helpButton.hidden = hidden
    }
}

// MARK: - ReactiveCocoa extensions

extension AppDelegate {
    // In this extension, I'm omitting [weak self] because the app delegate will outlive everyone.

    func showBuyersPremiumCommand(enabled: Observable<Bool> = just(true)) -> CocoaAction {
        return CocoaAction(enabledIf: enabled) { _ in
            self.hideAllTheThingsSignal()
                .then(self.showWebControllerSignal("https://m.artsy.net/auction/\(self.sale.id)/buyers-premium"))
                .map(void)
        }
    }

    func registerToBidCommand(enabled: Observable<Bool> = just(true)) -> CocoaAction {
        return CocoaAction(enabledIf: enabled) { _ in
            self.hideAllTheThingsSignal()
                .then(self.showRegistrationSignal())
                .map(void)
        }
    }

    func requestBidderDetailsCommand(enabled: Observable<Bool> = just(true)) -> CocoaAction {
        return CocoaAction(enabledIf: enabled) { _ in
            self.hideHelpSignal()
                .then(self.showBidderDetailsRetrievalSignal())
        }
    }

    func helpButtonCommand() -> CocoaAction {
        return CocoaAction { _ in
            let showHelpSignal = self.hideAllTheThingsSignal().then(self.showHelpSignal())

            return self.helpIsVisisbleSignal.take(1).flatMap { (visible: Bool) -> Observable<Void> in
                if visible {
                    return self.hideHelpSignal()
                } else {
                    return showHelpSignal
                }
            }
        }
    }

    func showPrivacyPolicyCommand() -> CocoaAction {
        return CocoaAction { _ in
            self.hideAllTheThingsSignal().then(self.showWebControllerSignal("https://artsy.net/privacy"))
        }
    }

    func showConditionsOfSaleCommand() -> CocoaAction {
        return CocoaAction { _ in
            self.hideAllTheThingsSignal().then(self.showWebControllerSignal("https://artsy.net/conditions-of-sale"))
        }
    }
}

// MARK: - Private ReactiveCocoa Extension

private extension AppDelegate {

    // MARK: - Signals that do things

    func ツ() -> Observable<Void>{
        return hideAllTheThingsSignal()
    }

    func hideAllTheThingsSignal() -> Observable<Void> {
        return self.closeFulfillmentViewControllerSignal().then(self.hideHelpSignal())
    }
    
    func showBidderDetailsRetrievalSignal() -> Observable<Void> {
        let appVC = self.appViewController
        let presentingViewController: UIViewController = (appVC.presentedViewController ?? appVC)
        return presentingViewController.promptForBidderDetailsRetrievalSignal()
    }

    func showRegistrationSignal() -> Observable<Void> {
        return create { observer in
            ARAnalytics.event("Register To Bid Tapped")

            let storyboard = UIStoryboard.fulfillment()
            let containerController = storyboard.instantiateInitialViewController() as! FulfillmentContainerViewController
            containerController.allowAnimations = self.appViewController.allowAnimations

            if let internalNav: FulfillmentNavigationController = containerController.internalNavigationController() {
                let registerVC = storyboard.viewControllerWithID(.RegisterAnAccount) as! RegisterViewController
                registerVC.placingBid = false
                internalNav.auctionID = self.appViewController.auctionID
                internalNav.viewControllers = [registerVC]
            }

            self.appViewController.presentViewController(containerController, animated: false) {
                containerController.viewDidAppearAnimation(containerController.allowAnimations)

                sendDispatchCompleted(observer)
            }

            return NopDisposable.instance
        }
    }

    func showHelpSignal() -> Observable<Void> {
        return create { observer in
            let helpViewController = HelpViewController()
            helpViewController.modalPresentationStyle = .Custom
            helpViewController.transitioningDelegate = self

            self.window?.rootViewController?.presentViewController(helpViewController, animated: true, completion: {
                self.helpViewController.value = helpViewController
                sendDispatchCompleted(observer)
            })

            return NopDisposable.instance
        }
    }

    // TODO: Correct animation?
    func closeFulfillmentViewControllerSignal() -> Observable<Void> {
        let closeSignal: Observable<Void> = create { observer in
            (self.appViewController.presentedViewController as? FulfillmentContainerViewController)?.closeFulfillmentModal() {
                sendDispatchCompleted(observer)
            }

            return NopDisposable.instance
        }

        return fullfilmentVisibleSignal.flatMap { visible -> Observable<Void> in
            if visible {
                return closeSignal
            } else {
                return empty()
            }
        }

    }

    func showWebControllerSignal(address: String) -> Observable<Void> {
        return hideWebViewControllerSignal().then (
            create { observer in
                let webController = ModalWebViewController(url: NSURL(string: address)!)

                let nav = UINavigationController(rootViewController: webController)
                nav.modalPresentationStyle = .FormSheet

                ARAnalytics.event("Show Web View", withProperties: ["url" : address])
                self.window?.rootViewController?.presentViewController(nav, animated: true) {
                    sendDispatchCompleted(observer)
                }

                self.webViewController = nav

                return NopDisposable.instance
            }
        )
    }

    func hideHelpSignal() -> Observable<Void> {
        return create { observer in
            if let presentingViewController = self.helpViewController.value?.presentingViewController {
                presentingViewController.dismissViewControllerAnimated(true) {
                    self.helpViewController.value = nil
                    sendDispatchCompleted(observer)
                }
            } else {
                observer.onCompleted()
            }


            return NopDisposable.instance
        }
    }

    func hideWebViewControllerSignal() -> Observable<Void> {
        return create { observer in
            if let webViewController = self.webViewController {
                webViewController.presentingViewController?.dismissViewControllerAnimated(true) { () -> Void in
                    sendDispatchCompleted(observer)
                }
            } else {
                observer.onCompleted()
            }

            return NopDisposable.instance
        }
    }

    // MARK: - Computed property signals

    var fullfilmentVisibleSignal: Observable<Bool> {
        return deferred {
            return create { observer in
                observer.onNext((self.appViewController.presentedViewController as? FulfillmentContainerViewController) != nil)
                observer.onCompleted()

                return NopDisposable.instance
            }
        }
    }

    var helpIsVisisbleSignal: Observable<Bool> {
        return helpViewController.asObservable().map { controller in
            return controller.hasValue
        }
    }
}

// MARK: - Help transtion animation

extension AppDelegate: UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HelpAnimator(presenting: true)
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HelpAnimator()
    }
}
