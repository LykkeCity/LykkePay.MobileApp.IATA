import Foundation
import UIKit

class BaseAuthViewController: UIViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    func showErrorAlert(error : Error) {
        let message = error.localizedDescription
        let uiAlert = UIAlertController(title: "Common.Title.Error".localize(), message: message, preferredStyle: UIAlertControllerStyle.alert)
            self.present(uiAlert, animated: true, completion: nil)
            
            uiAlert.addAction(UIAlertAction(title: "Common.PositiveButton.Ok".localize(), style: .default, handler: nil))
    }
    
    @objc func appMovedToBackground() {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}
