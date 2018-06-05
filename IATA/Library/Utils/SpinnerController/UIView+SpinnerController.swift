import Foundation
import ObjectiveC
import UIKit

extension UIView {
    private static var spinnerControllerKey: UInt8 = 0
    
    public var spinnerController: SpinnerController {
        guard let storedSC = objc_getAssociatedObject(self, &UIView.spinnerControllerKey) as? SpinnerController else {
            let newSC = SpinnerController(with: self)
            objc_setAssociatedObject(self, &UIView.spinnerControllerKey, newSC,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return newSC
        }
        return storedSC
    }
}
