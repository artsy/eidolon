import UIKit
import QuartzCore
import ARAnalytics
import RxSwift
import Action

func appDelegate() -> AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
}

extension AppDelegate {

    // Registration

    var sale: Sale! {
        return appViewController!.sale.value
    }

    internal var appViewController: AppViewController! {
        let nav = self.window?.rootViewController?.findChildViewControllerOfType(UINavigationController) as? UINavigationController
        return nav?.delegate as? AppViewController
    }

    // Help button and menu

    func setupHelpButton() {
        helpButton = MenuButton()
        helpButton.setTitle("Help", for: .normal)
        helpButton.rx_action = helpButtonCommand()
        window?.addSubview(helpButton)
        helpButton.alignTop(nil, leading: nil, bottom: "-24", trailing: "-24", to: window)
        window?.layoutIfNeeded()

        helpIsVisisble.subscribeNext { visisble in
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

    func setHelpButtonHidden(_ hidden: Bool) {
        helpButton.isHidden = hidden
    }
}

// MARK: - ReactiveCocoa extensions

extension AppDelegate {
    // In this extension, I'm omitting [weak self] because the app delegate will outlive everyone.

    func showBuyersPremiumCommand(enabled: Observable<Bool> = .just(true)) -> CocoaAction {
        return CocoaAction(enabledIf: enabled) { _ in
            self.hideAllTheThings()
                .then(self.showWebController("https://m.artsy.net/auction/\(self.sale.id)/buyers-premium"))
                .map(void)
        }
    }

    func registerToBidCommand(enabled: Observable<Bool> = .just(true)) -> CocoaAction {
        return CocoaAction(enabledIf: enabled) { _ in
            self.hideAllTheThings()
                .then(self.showRegistration())
        }
    }

    func requestBidderDetailsCommand(enabled: Observable<Bool> = .just(true)) -> CocoaAction {
        return CocoaAction(enabledIf: enabled) { _ in
            self.hideHelp()
                .then(self.showBidderDetailsRetrieval())
        }
    }

    func helpButtonCommand() -> CocoaAction {
        return CocoaAction { _ in
            let showHelp = self.hideAllTheThings().then(self.showHelp())

            return self.helpIsVisisble.take(1).flatMap { (visible: Bool) -> Observable<Void> in
                if visible {
                    return self.hideHelp()
                } else {
                    return showHelp
                }
            }
        }
    }

    func showPrivacyPolicyCommand() -> CocoaAction {
        return CocoaAction { _ in
            self.hideAllTheThings().then(self.showWebController("https://artsy.net/privacy"))
        }
    }

    func showConditionsOfSaleCommand() -> CocoaAction {
        return CocoaAction { _ in
            self.hideAllTheThings().then(self.showWebController("https://artsy.net/conditions-of-sale"))
        }
    }
}

// MARK: - Private ReactiveCocoa Extension

private extension AppDelegate {

    // MARK: - s that do things

    func ツ() -> Observable<Void>{
        return hideAllTheThings()
    }

    func hideAllTheThings() -> Observable<Void> {
        return self.closeFulfillmentViewController().then(self.hideHelp())
    }
    
    func showBidderDetailsRetrieval() -> Observable<Void> {
        let appVC = self.appViewController
        let presentingViewController: UIViewController = (appVC!.presentedViewController ?? appVC!)
        return presentingViewController.promptForBidderDetailsRetrieval(self.provider)
    }

    func showRegistration() -> Observable<Void> {
        return Observable.create { observer in
            ARAnalytics.event("Register To Bid Tapped")

            let storyboard = UIStoryboard.fulfillment()
            let containerController = storyboard.instantiateInitialViewController() as! FulfillmentContainerViewController
            containerController.allowAnimations = self.appViewController.allowAnimations

            if let internalNav: FulfillmentNavigationController = containerController.internalNavigationController() {
                internalNav.auctionID = self.appViewController.auctionID
                let registerVC = storyboard.viewControllerWithID(.RegisterAnAccount) as! RegisterViewController
                registerVC.placingBid = false
                registerVC.provider = self.provider
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

    func showHelp() -> Observable<Void> {
        return Observable.create { observer in
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

    func closeFulfillmentViewController() -> Observable<Void> {
        let close: Observable<Void> = Observable.create { observer in
            (self.appViewController.presentedViewController as? FulfillmentContainerViewController)?.closeFulfillmentModal() {
                sendDispatchCompleted(observer)
            }

            return NopDisposable.instance
        }

        return fullfilmentVisible.flatMap { visible -> Observable<Void> in
            if visible {
                return close
            } else {
                return .empty()
            }
        }

    }

    func showWebController(address: String) -> Observable<Void> {
        return hideWebViewController().then (
            Observable.create { observer in
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

    func hideHelp() -> Observable<Void> {
        return Observable.create { observer in
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

    func hideWebViewController() -> Observable<Void> {
        return Observable.create { observer in
            if let webViewController = self.webViewController {
                webViewController.presentingViewController?.dismissViewControllerAnimated(true) {
                    sendDispatchCompleted(observer)
                }
            } else {
                observer.onCompleted()
            }

            return NopDisposable.instance
        }
    }

    // MARK: - Computed property observables

    var fullfilmentVisible: Observable<Bool> {
        return Observable.deferred {
            return Observable.create { observer in
                observer.onNext((self.appViewController.presentedViewController as? FulfillmentContainerViewController) != nil)
                observer.onCompleted()

                return NopDisposable.instance
            }
        }
    }

    var helpIsVisisble: Observable<Bool> {
        return helpViewController.asObservable().map { controller in
            return controller.hasValue
        }
    }
}

// MARK: - Help transtion animation

extension AppDelegate: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HelpAnimator(presenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HelpAnimator()
    }
}
