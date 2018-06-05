import UIKit

extension UIView {
    
    static internal func getEmptyIntersectionalView() -> UIView {
        let view = UIView()
        view.backgroundColor = Theme.shared.munsellColor
        
        return view
    }
}
