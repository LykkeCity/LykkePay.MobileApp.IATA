import Foundation
import UIKit

class BaseAuthViewController: UIViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    func showErrorAlert(error : Error) {
        var message = ""
        if (error is IATAOpError) {
            message = (error as! IATAOpError).localizedDescription
        } else {
            message = error.localizedDescription
        }
        let uiAlert = UIAlertController(title: R.string.localizable.commonTitleError(), message: message, preferredStyle: UIAlertControllerStyle.alert)
            self.present(uiAlert, animated: true, completion: nil)
            
            uiAlert.addAction(UIAlertAction(title: R.string.localizable.commonPositiveButtonOk(), style: .default, handler: nil))
    }
    
    @objc func appMovedToBackground() {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}
