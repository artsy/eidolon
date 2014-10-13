import UIKit

class HelpAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let presenting: Bool
    
    init(presenting: Bool = false) {
        self.presenting = presenting
        super.init()
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return AnimationDuration.Normal
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView()
        
        if presenting {
            let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
            let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)! as HelpViewController
            
            fromViewController.view.userInteractionEnabled = false
            
            containerView.backgroundColor = UIColor.blackColor()
            
            containerView.addSubview(fromViewController.view)
            containerView.addSubview(toViewController.view)
            
            toViewController.view.alignTop("0", bottom: "0", toView: containerView)
            toViewController.view.constrainWidth("\(HelpViewController.width)")
            toViewController.positionConstraints = toViewController.view.alignAttribute(.Left, toAttribute: .Right, ofView: containerView, predicate: "0")
            containerView.layoutIfNeeded()
            
            UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
                containerView.removeConstraints(toViewController.positionConstraints ?? [])
                toViewController.positionConstraints = toViewController.view.alignLeading(nil, trailing: "0", toView: containerView)
                containerView.layoutIfNeeded()
                
                fromViewController.view.alpha = 0.5
            }, completion: { (value: Bool) in
                transitionContext.completeTransition(true)
            })
        } else {
            let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)! as HelpViewController
            let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
            
            toViewController.view.userInteractionEnabled = true
            
            containerView.addSubview(toViewController.view)
            containerView.addSubview(fromViewController.view)
            
            UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: {
                containerView.removeConstraints(fromViewController.positionConstraints ?? [])
                fromViewController.positionConstraints = fromViewController.view.alignAttribute(.Left, toAttribute: .Right, ofView: containerView, predicate: "0")
                containerView.layoutIfNeeded()
                
                toViewController.view.alpha = 1.0
            }, completion: { (value: Bool) in
                transitionContext.completeTransition(true)
                // This following line is to work around a bug in iOS 8 💩
                UIApplication.sharedApplication().keyWindow!.insertSubview(toViewController.view, atIndex: 0)
            })
        }
    }
}
