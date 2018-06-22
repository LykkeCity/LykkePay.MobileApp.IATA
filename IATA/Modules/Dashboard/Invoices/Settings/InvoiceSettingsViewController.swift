import UIKit

class InvoiceSettingsViewController: UIViewController {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    private let viewModel = InvoiceViewModel()
    private var isShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView?.dataSource = viewModel
        self.tableView?.delegate = viewModel
        
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.estimatedRowHeight = 55
        self.tableView?.separatorColor = Theme.shared.dotColor
        
        initHeaderCells()
        
        self.tableView?.register(PaymentRangeTableViewCell.nib, forCellReuseIdentifier: PaymentRangeTableViewCell.identifier)
        self.tableView?.register(InvoiceSettingsTableViewCell.nib, forCellReuseIdentifier: InvoiceSettingsTableViewCell.identifier)
    
        initKeyboardEvents()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.disableDoneButton),
            name: NSNotification.Name(NotificateDoneEnum.disable.rawValue),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.enableDoneButton),
            name: NSNotification.Name(NotificateDoneEnum.enable.rawValue),
            object: nil)
        self.setNeedsStatusBarAppearanceUpdate()
        self.initNavBar()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    @IBAction func clickCancel(_ sender: Any) {
        NavPushingUtil.shared.pop(navigationController: self.navigationController)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if (!isShown) {
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.bottomConstraint.constant = keyboardSize.size.height/2 + 100
                    self.viewModel.scrollToLastPosition(tableView: self.tableView)
                })
                isShown = true
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if (isShown) {
           self.bottomConstraint.constant = 0
            isShown = false
        }
    }
    
    @objc func clickDone() {
        self.viewModel.state.clickDone()
        NavPushingUtil.shared.pop(navigationController: self.navigationController)
    }
    
    @objc func disableDoneButton() {
        self.initRightButton(isEnabled: false)
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    @objc func enableDoneButton() {
        self.initRightButton(isEnabled: true)
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initNavBar()
    }
    
    private func initNavBar() {
        self.setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = Theme.shared.greyNavBar
        self.navigationController?.navigationBar.tintColor = Theme.shared.navBarTitle
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: Theme.shared.navBarTitle]
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        self.initBackButton()
        self.initRightButton(isEnabled: true)
        self.initTitle()
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        self.navigationController?.navigationBar.layoutIfNeeded()
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    private func initBackButton() {
        let backButton = Theme.shared.getCancel(title: R.string.localizable.commonNavBarCancel(), color: Theme.shared.navBarTitle)
        backButton.addTarget(self, action: #selector(clickCancel), for: .touchUpInside)
        
        let backItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backItem
    }
    
    private func initRightButton(isEnabled: Bool) {
        let rightButton = Theme.shared.getRightButton(title: R.string.localizable.commonNavBarDone(), color: isEnabled ? Theme.shared.textFieldColor : Theme.shared.disbaledRightButton)
        rightButton.addTarget(self, action: #selector(clickDone), for: .touchUpInside)
        
        let rightItem = UIBarButtonItem(customView: rightButton)
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    private func initTitle() {
        let titleLabel = Theme.shared.getTitle(title: R.string.localizable.invoiceSettingsFilterTitle(), color: Theme.shared.navBarTitle)
        self.navigationItem.titleView = titleLabel
    }
    
    private func initKeyboardEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    private func initHeaderCells() {
        let dummyViewHeight = CGFloat(60)
        self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyViewHeight))
        self.tableView.contentInset = UIEdgeInsetsMake(-dummyViewHeight, 0, 0, 0)
        
        self.tableView.register(InvoiceHeaderView.nib, forHeaderFooterViewReuseIdentifier: InvoiceHeaderView.identifier)
    }
}
