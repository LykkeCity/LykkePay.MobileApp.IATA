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
        navigationController?.pushViewController(controller, animated: false)
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
