import Foundation
import UIKit

class BaseAuthViewController: UIViewController {
    
    func showErrorAlert(error : Error) {
        if (error is IATAOpError) {
            let uiAlert = UIAlertController(title: "Common.Title.Error".localize(), message: (error as! IATAOpError).localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
            self.present(uiAlert, animated: true, completion: nil)
            
            uiAlert.addAction(UIAlertAction(title: "Common.PositiveButton.Ok".localize(), style: .default, handler: nil))
        }
    }
    
}
