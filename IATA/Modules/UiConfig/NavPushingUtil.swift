import Foundation
import UIKit

class NavPushingUtil {
}

class PresentAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    weak var storedContext: UIViewControllerContextTransitioning?
    var operation: UINavigationControllerOperation = .push
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerVw = transitionContext.containerView
        let fromViewController = transitionContext.viewController(forKey: .from)
        let toViewController = transitionContext.viewController(forKey: .to)
        guard let fromVc = fromViewController, let toVc = toViewController else { return }
        let finalFrame = transitionContext.finalFrame(for: toVc)
        toVc.view.frame = finalFrame.offsetBy(dx: 0, dy: finalFrame.size.height)
        
        containerVw.addSubview(toVc.view)
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toVc.view.frame = finalFrame
        }, completion: {(finished) in
            transitionContext.completeTransition(finished)
        })
        
        storedContext = transitionContext
    }
    
    
}

class PresentDownAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    weak var storedContext: UIViewControllerContextTransitioning?
    var operation: UINavigationControllerOperation = .push
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
   
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerVw = transitionContext.containerView
        let fromViewController = transitionContext.viewController(forKey: .from)
        let toViewController = transitionContext.viewController(forKey: .to)
        guard let fromVc = fromViewController, let toVc = toViewController else { return }
        let finalFrame = transitionContext.finalFrame(for: toVc)
        toVc.view.frame = finalFrame
        fromVc.view.frame = finalFrame.offsetBy(dx: 0, dy: 0)
        
        containerVw.addSubview(toVc.view)
        containerVw.addSubview(fromVc.view)
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
           fromVc.view.frame = finalFrame.offsetBy(dx: 0, dy: finalFrame.size.height * 2)
        }, completion: {(finished) in
            transitionContext.completeTransition(finished)
        })
        
        storedContext = transitionContext
    }
    
    
}


