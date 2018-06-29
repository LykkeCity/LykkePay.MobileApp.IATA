import UIKit

class InvoiceSettingsViewController: BaseNavController {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navView: UIView!
    
    private var isShown = false
    private var isEnabled = true
    var rootController: InvoiceViewController?
    var completion: (() -> Void) = {}
    var viewModel =  InvoiceViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.dataSource = viewModel
        self.tableView?.delegate = viewModel
        
        self.tableView?.showsVerticalScrollIndicator = false
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.estimatedRowHeight = 55
        self.tableView?.separatorStyle = .none
        
        initHeaderCells()
        
        self.tableView?.register(PaymentRangeTableViewCell.nib, forCellReuseIdentifier: PaymentRangeTableViewCell.identifier)
        self.tableView?.register(InvoiceSettingsTableViewCell.nib, forCellReuseIdentifier: InvoiceSettingsTableViewCell.identifier)
        
        initKeyboardEvents()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.disableDoneButton),
            name: NSNotification.Name(NotificateEnum.disable.rawValue),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.enableDoneButton),
            name: NSNotification.Name(NotificateEnum.enable.rawValue),
            object: nil)
        self.setNeedsStatusBarAppearanceUpdate()
        self.initNavBar()
        
        self.loadData()
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func getTitleView() -> UIView {
        return Theme.shared.getTitle(title: self.getTitle(), color: Theme.shared.navBarTitle)
    }
    
    override func getTableView() -> UITableView {
        return self.tableView
    }
    
    @IBAction func clickCancel(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(NotificateEnum.destroy.rawValue), object: nil)
        self.dismiss(animated: true, completion: nil)
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
         NotificationCenter.default.post(name: NSNotification.Name(NotificateEnum.destroy.rawValue), object: nil)
        self.viewModel.state.clickDone()
        self.rootController?.beginRefreshing()
        self.dismiss(animated: true, completion: completion)
    }
    
    @objc func disableDoneButton() {
        self.isEnabled = false
        self.getNavItem()?.rightBarButtonItem = getRightButton()
        self.getNavItem()?.rightBarButtonItem?.isEnabled = false
    }
    
    @objc func enableDoneButton() {
        self.isEnabled = true
        self.getNavItem()?.rightBarButtonItem = getRightButton()
        self.getNavItem()?.rightBarButtonItem?.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initNavBar()
    }
    
    override func getNavBar() -> UINavigationBar? {
        return self.navBar
    }
    
    override func getNavView() -> UIView? {
        return self.navView
    }
    
    override func getNavItem() -> UINavigationItem? {
        return self.navItem
    }
    
    override func initNavBar() {
        self.backgroundNavBar = Theme.shared.greyNavBar
        super.initNavBar()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        self.getNavBar()?.layoutIfNeeded()
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func getLeftButton() -> UIBarButtonItem? {
        let backButton = Theme.shared.getCancel(title: R.string.localizable.commonNavBarCancel(), color: Theme.shared.navBarTitle)
        backButton.addTarget(self, action: #selector(clickCancel), for: .touchUpInside)
        
        return UIBarButtonItem(customView: backButton)
    }
    
    override func getRightButton() -> UIBarButtonItem? {
        let rightButton = Theme.shared.getRightButton(title: R.string.localizable.commonNavBarDone(), color: isEnabled ? Theme.shared.textFieldColor : Theme.shared.disbaledRightButton)
        rightButton.addTarget(self, action: #selector(clickDone), for: .touchUpInside)
        
        return UIBarButtonItem(customView: rightButton)
    }
    
    override func getTitle() -> String? {
        return R.string.localizable.invoiceSettingsFilterTitle()
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
    
    @objc func loadData() {
        self.viewModel.state.getFilters()
            .withSpinner(in: self.view)
            .then(execute: { [weak self] (result: FiltersInvoiceList) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.initResult(result: result)
            })
    }
    
    private func initResult(result: FiltersInvoiceList) {
        self.viewModel.state.initItems(model: result)
        self.tableView.reloadData()
    }
}
