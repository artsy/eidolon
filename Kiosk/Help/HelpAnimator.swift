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
        
        
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey) ?? transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!.view
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey) ?? transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!.view
        
        let a = transitionContext.viewForKey(UITransitionContextFromViewKey)
        let b = transitionContext.viewForKey(UITransitionContextToViewKey)

        if presenting {
            let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)! as HelpViewController
            
            fromView.userInteractionEnabled = false
            
            containerView.backgroundColor = UIColor.blackColor()
            
            containerView.addSubview(fromView)
            containerView.addSubview(toView)
            
            toView.alignTop("0", bottom: "0", toView: containerView)
            toView.constrainWidth("\(HelpViewController.width)")
            toViewController.positionConstraints = toView.alignAttribute(.Left, toAttribute: .Right, ofView: containerView, predicate: "0")
            containerView.layoutIfNeeded()
            
            UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
                containerView.removeConstraints(toViewController.positionConstraints ?? [])
                toViewController.positionConstraints = toView.alignLeading(nil, trailing: "0", toView: containerView)
                containerView.layoutIfNeeded()
                
                fromView.alpha = 0.5
            }, completion: { (value: Bool) in
                transitionContext.completeTransition(true)
            })
        } else {
            let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)! as HelpViewController
            
            toView.userInteractionEnabled = true
            
            containerView.addSubview(toView)
            containerView.addSubview(fromView)
            
            UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: {
                containerView.removeConstraints(fromViewController.positionConstraints ?? [])
                fromViewController.positionConstraints = fromView.alignAttribute(.Left, toAttribute: .Right, ofView: containerView, predicate: "0")
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
