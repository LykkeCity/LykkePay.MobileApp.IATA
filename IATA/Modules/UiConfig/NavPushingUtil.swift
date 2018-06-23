import Foundation
import UIKit

class NavPushingUtil {
    
    public static private(set) var shared = NavPushingUtil()
    
    public func push(navigationController: UINavigationController?, controller: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromTop
        navigationController?.view.layer.add(transition, forKey: nil)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    public func pop(navigationController: UINavigationController?) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromBottom
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.popViewController(animated: false)
    }
    
    public func pushDown(navigationController: UINavigationController?, controller: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromBottom
        navigationController?.view.layer.add(transition, forKey: nil)
        navigationController?.pushViewController(controller, animated: false)
    }
}

class CustomPushAnimation: NSObject, UIViewControllerAnimatedTransitioning {
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
        fromVc.view.frame = CGRect(x: 0, y: 44, width: fromVc.view.frame.width, height: fromVc.view.frame.height+44+44)
        
        if let view = fromVc.navigationController?.navigationBar, let copied = copyView(view: view){
            copied.backgroundColor = .blue
            copied.frame = CGRect(x: 0, y: 0, width: copied.frame.width, height: copied.frame.height)
            fromVc.view.addSubview(copied)
            let view = UIView()
            view.frame = CGRect(x: 0, y: -24, width: copied.frame.width, height: 24)
            view.backgroundColor =  .white
            fromVc.view.addSubview(view)
        }
        
        
        fromVc.view.frame = CGRect(x: 0, y: 24, width: fromVc.view.frame.width, height: fromVc.view.frame.height+44+24)
        
        if let oldRect = toViewController?.navigationController?.navigationBar.frame {
            toViewController?.navigationController?.navigationBar.frame = CGRect(x: 0, y: finalFrame.size.height + 44, width: oldRect.width, height: oldRect.height)
        }
        
        containerVw.addSubview(toVc.view)
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toVc.view.frame = finalFrame
            toViewController?.navigationController?.navigationBar.frame = finalFrame.offsetBy(dx: 0, dy: -44)
        }, completion: {(finished) in
            transitionContext.completeTransition(finished)
        })
        
        storedContext = transitionContext
    }
    
    func copyView(view: UIView) -> UIView?
    {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: view)) as? UIView
    }
    
    
}

