import Foundation
import UIKit


class BaseNavController: UIViewController {
    
    var initializer: Initializer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
}
