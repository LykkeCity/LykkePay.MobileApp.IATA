import Foundation
import UIKit


class BaseNavController: UIViewController, UITextFieldDelegate {
    
    var backgroundNavBar: UIColor = Theme.shared.navigationBarColor
    var textTitleColor: UIColor = UIColor.white
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        setUp()
        initNavBar()
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
    
    func initNavBar() {
        self.navigationController?.isNavigationBarHidden = true
        self.setNeedsStatusBarAppearanceUpdate()
        self.getNavBar()?.barStyle = .blackOpaque
        self.navigationController?.navigationBar.barTintColor = backgroundNavBar
        self.getNavBar()?.barTintColor = backgroundNavBar
        self.getNavView()?.backgroundColor = backgroundNavBar
        self.getNavBar()?.tintColor = .white
        self.getNavBar()?.isTranslucent = false
        self.getNavItem()?.titleView = getTitleView()
        self.getNavItem()?.leftBarButtonItem  = getLeftButton()
        self.getNavItem()?.rightBarButtonItem  = getRightButton()
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        self.getNavBar()?.layoutIfNeeded()
        self.getNavView()?.tintColor = backgroundNavBar
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func setUp() {
        
    }

    func getTitle() -> String? {
        return nil
    }

    func getTableView() -> UITableView {
        return UITableView()
    }

    func registerCells() {
        
    }
    
    func getTitleView() -> UIView {
        return Theme.shared.getTitle(title: self.getTitle(), color: textTitleColor)
    }
    
    func getLeftButton() -> UIBarButtonItem? {
        return nil
    }
    
    func getRightButton() -> UIBarButtonItem? {
        return nil
    }
    
    @objc func appMovedToBackground() {
        self.view.endEditing(true)
    }
    
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func getNavBar() -> UINavigationBar? {
        return self.navigationController?.navigationBar
    }
    
    func getNavView() -> UIView? {
        return nil
    }
    
    func getNavItem() -> UINavigationItem? {
        return self.navigationItem
    }
   
}
