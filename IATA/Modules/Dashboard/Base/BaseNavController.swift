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
        UINavigationBar.appearance().barStyle = .blackOpaque
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        self.navigationController?.navigationBar.barTintColor = Theme.shared.tabBarBackgroundColor
        self.navigationController?.navigationBar.tintColor = .white
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
    
    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = R.font.gothamProLight(size: 12)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
