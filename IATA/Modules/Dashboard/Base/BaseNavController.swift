import Foundation
import UIKit


class BaseNavController: UIViewController, UITextFieldDelegate {
    
    var initializer: Initializer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        setUp()
        initNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initNavBar()
    }
    
    func initNavBar() {
        self.navigationController?.navigationBar.barTintColor = Theme.shared.tabBarBackgroundColor
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.navigationItem.titleView = getTitleView()
        self.navigationItem.leftBarButtonItem  = getLeftButton()
        self.navigationItem.rightBarButtonItem  = getRightButton()
    
    }
    
    func setUp() {
        
    }
    
    func getTitleView() -> UIView {
        return Theme.shared.getTitle(title: self.initializer?.getTitle(), color: UIColor.white)
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
}
