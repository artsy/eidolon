import UIKit
import RxSwift

class HelpAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let presenting: Bool
    
    init(presenting: Bool = false) {
        self.presenting = presenting
        super.init()
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return AnimationDuration.Normal
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView()!
        
        let fromView:UIView! = transitionContext.viewForKey(UITransitionContextFromViewKey) ?? transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!.view
        let toView:UIView! = transitionContext.viewForKey(UITransitionContextToViewKey) ?? transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!.view

        if presenting {
            let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)! as! HelpViewController
            
            let dismissTapGestureRecognizer = UITapGestureRecognizer()
            dismissTapGestureRecognizer.rac_gestureSignal().subscribeNext{ [weak toView] (sender) -> Void in
                let dismissTapGestureRecognizer = sender as! UITapGestureRecognizer
                let pointInContainer = dismissTapGestureRecognizer.locationInView(toView)
                if toView?.pointInside(pointInContainer, withEvent: nil) == false {
                    appDelegate().helpButtonCommand().execute(dismissTapGestureRecognizer)
                }
            }
            toViewController.dismissTapGestureRecognizer = dismissTapGestureRecognizer
            containerView.addGestureRecognizer(dismissTapGestureRecognizer)

            fromView.userInteractionEnabled = false
            
            containerView.backgroundColor = .blackColor()
            
            containerView.addSubview(fromView)
            containerView.addSubview(toView)
            
            toView.alignTop("0", bottom: "0", toView: containerView)
            toView.constrainWidth("\(HelpViewController.width)")
            toViewController.positionConstraints = toView.alignAttribute(.Left, toAttribute: .Right, ofView: containerView, predicate: "0") as? [NSLayoutConstraint]
            containerView.layoutIfNeeded()
            
            UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
                containerView.removeConstraints(toViewController.positionConstraints ?? [])
                toViewController.positionConstraints = toView.alignLeading(nil, trailing: "0", toView: containerView) as? [NSLayoutConstraint]
                containerView.layoutIfNeeded()
                
                fromView.alpha = 0.5
            }, completion: { (value: Bool) in
                transitionContext.completeTransition(true)
            })
        } else {
            let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)! as! HelpViewController
            
            if let dismissTapGestureRecognizer = fromViewController.dismissTapGestureRecognizer {
                containerView.removeGestureRecognizer(dismissTapGestureRecognizer)
            }

            toView.userInteractionEnabled = true
            
            containerView.addSubview(toView)
            containerView.addSubview(fromView)
            
            UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: {
                containerView.removeConstraints(fromViewController.positionConstraints ?? [])
                fromViewController.positionConstraints = fromView.alignAttribute(.Left, toAttribute: .Right, ofView: containerView, predicate: "0") as? [NSLayoutConstraint]
                containerView.layoutIfNeeded()
                
                toView.alpha = 1.0
            }, completion: { (value: Bool) in
                transitionContext.completeTransition(true)
                // This following line is to work around a bug in iOS 8 💩
                UIApplication.sharedApplication().keyWindow!.insertSubview(transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!.view, atIndex: 0)
            })
        }
    }
}
