import UIKit

class InvoiceSettingsViewController: UIViewController {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    private let viewModel = InvoiceViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationBar.appearance().barStyle = .black
        
        self.tableView?.dataSource = viewModel
        self.tableView?.delegate = viewModel
        
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.estimatedRowHeight = 55
        self.tableView?.separatorColor = Theme.shared.dotColor
        
        let dummyViewHeight = CGFloat(80)
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyViewHeight))
        self.tableView.contentInset = UIEdgeInsetsMake(-dummyViewHeight, 0, 0, 0)
        
        self.tableView.register(InvoiceHeaderView.nib, forHeaderFooterViewReuseIdentifier: InvoiceHeaderView.identifier)
        
        self.tableView?.register(PaymentRangeTableViewCell.nib, forCellReuseIdentifier: PaymentRangeTableViewCell.identifier)
        self.tableView?.register(InvoiceSettingsTableViewCell.nib, forCellReuseIdentifier: InvoiceSettingsTableViewCell.identifier)
    
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func clickCancel(_ sender: Any) {
        NavPushingUtil.shared.pop(navigationController: self.navigationController)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.bottomConstraint.constant = keyboardSize.size.height/2 + 20
                self.viewModel.scrollToLastPosition(tableView: self.tableView)
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.bottomConstraint.constant = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initNavBar()
    }
    
    private func initNavBar() {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = Theme.shared.navBarTitle
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: Theme.shared.navBarTitle]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        self.initBackButton()
        self.initRightButton()
        self.initTitle()
    }
    
    private func initBackButton() {
        let backButton = Theme.shared.getCancel(title: R.string.localizable.commonNavBarCancel(), color: Theme.shared.navBarTitle)
        backButton.addTarget(self, action: #selector(clickCancel), for: .touchUpInside)
        
        let backItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backItem
    }
    
    private func initRightButton() {
        let rightButton = Theme.shared.getRightButton(title: R.string.localizable.commonNavBarDone(), color: Theme.shared.textFieldColor)
        rightButton.addTarget(self, action: #selector(clickDone), for: .touchUpInside)
        
        let rightItem = UIBarButtonItem(customView: rightButton)
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    private func initTitle() {
        let titleLabel = Theme.shared.getTitle(title: R.string.localizable.invoiceSettingsFilterTitle(), color: Theme.shared.navBarTitle)
        self.navigationItem.titleView = titleLabel
    }
    
    @objc func clickDone() {
        self.viewModel.state.clickDone()
        NavPushingUtil.shared.pop(navigationController: self.navigationController)
    }
}
