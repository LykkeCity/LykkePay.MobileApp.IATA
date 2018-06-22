
import Foundation
import UIKit

class ViewUtils {
    
    var toastLabel: UILabel?
    
    required init() {}
    
    func showToast(message : String, view: UIView) {
        if let currentLabel = toastLabel, currentLabel.isDescendant(of: view){
            currentLabel.removeFromSuperview()
        }
        
        toastLabel = UILabel(frame: CGRect(x: view.frame.size.width/2 - 150, y: 100, width: 300, height: 35))
        if let currentLabel = toastLabel {
            currentLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            currentLabel.textColor = UIColor.white
            currentLabel.textAlignment = .center;
            currentLabel.font = R.font.gothamProLight(size: 12)
            currentLabel.text = message
            currentLabel.alpha = 1.0
            currentLabel.layer.cornerRadius = 10;
            currentLabel.clipsToBounds  =  true
            view.addSubview(currentLabel)
            UIView.animate(withDuration: 10.0, delay: 0.1, options: .curveEaseOut, animations: {
                currentLabel.alpha = 0.0
            }, completion: {(isCompleted) in
                currentLabel.removeFromSuperview()
            })
        }
    }
        
        public static private(set) var shared = ViewUtils()
}
