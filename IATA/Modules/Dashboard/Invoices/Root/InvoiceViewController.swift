import UIKit
import ObjectMapper

class InvoiceViewController: BaseViewController<InvoiceModel, DefaultInvoiceState> {
   
    @IBOutlet weak var sumTextField: CurrencyUiTextField!
    @IBOutlet weak var btnPay: UIButton!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var tabView: UITableView!
    @IBOutlet weak var downView: UIView!
    @IBOutlet weak var selectedItemTextField: UILabel!
    @IBOutlet weak var downViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var payHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomConstrain: NSLayoutConstraint!
    @IBOutlet weak var placeholderInvoice: UIView!

    private var viewModel: InvoiceRootViewModel? = nil

    internal lazy var walletsState = DefaultWalletsState()
    internal var totalBalance: Double?
    var isDisabledValue: Bool = false
    
   
    
    override func viewDidLoad() {
        state = DefaultInvoiceState()
        viewModel = InvoiceRootViewModel(state: state, viewController: self)
        super.viewDidLoad()
        self.beginRefreshing()
        self.loadData()
        checkCurrentBalance()
        
        self.sumTextField.delegate = self
        self.sumTextField.addObservers()
        
        self.navigationController?.isNavigationBarHidden = false
        Theme.shared.configureTextFieldCurrencyStyle(self.sumTextField)
        
        self.downViewHeightConstraint.constant = 0
        self.payHeight.constant = 0
        self.initKeyboardEvents()

        //better use protocol - will rewrite later
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "loadData"), object: nil)
        //let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        //view.addGestureRecognizer(tap)
    }

    override func appMovedToBackground() {
        super.appMovedToBackground()
        hideMenu()
    }

     override func endRefreshAnimation(wasEmpty: Bool, dataFetched: Bool){
        super.endRefreshAnimation(wasEmpty: wasEmpty, dataFetched: dataFetched)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.isDisabledValue = false
        })
    }
    
    override func beginRefreshing(){
        super.beginRefreshing()
        self.isDisabledValue =  true
    }
    
    @IBAction func makePay(_ sender: Any) {
        guard let amount = self.sumTextField.text else {
            return
        }
        
        guard let symbol = UserPreference.shared.getCurrentCurrency()?.symbol else {
            return
        }
        
        let amountConverted = Formatter.formattedWithSeparator(value: amount)
        let message = R.string.localizable.invoiceScreenPaymentMessage(symbol + " " + amountConverted)
        self.view.endEditing(true)
        generatePaymentAlert(message: message, handler: makePayment)
    }
    
    @IBAction func sumChanged(_ sender: Any) {
        if let text = self.sumTextField.text, let isEmpty = self.sumTextField.text?.isEmpty, isEmpty || Formatter.formattedToDouble(valueString: text) == 0 {
            setEnabledPay(isEnabled: false)
            if let separator = NSLocale.current.decimalSeparator, text.contains(separator) {
                self.sumTextField.alpha = 1
            }
        } else {
            setEnabledPay(isEnabled: true)
        }
    }
    
    @objc func clickFilter(sender: Any?) {
        let viewController = InvoiceSettingsViewController()
        viewController.rootController = self
        viewController.setNeedsStatusBarAppearanceUpdate()
        viewController.completion = {
            self.loadData()
        }
        self.navigationController?.present(viewController, animated: true, completion: nil)
        self.hideMenu()
    }
    
    @objc func clickDispute(sender: Any?) {
        let viewController = DisputeViewController()
        self.navigationController?.present(viewController, animated: true, completion: nil)
        self.hideMenu()
    }
    
    override func loadData() {
        self.viewModel?.loadData()
    }
    
    override func getLeftButton() -> UIBarButtonItem? {
        return UIBarButtonItem(image: R.image.ic_filter(), style: .plain, target: self, action: #selector(self.clickFilter(sender:)))
    }
    
    override func getRightButton() -> UIBarButtonItem? {
        return UIBarButtonItem(image: R.image.ic_dispute(), style: .plain, target: self, action: #selector(self.clickDispute(sender:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.sumTextField.symbolValue = UserPreference.shared.getCurrentCurrency()?.symbol
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        self.hideMenu()
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let model = viewModel {
            return model.tableView(tableView, cellForRowAt: indexPath)
        } else {
            return UITableViewCell()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismissKeyboard()
        if let item = self.state?.getItems()[indexPath.row] {
            let viewController = TransactionViewController()
            viewController.isPaid = self.state?.getItems()[indexPath.row].status == InvoiceStatuses.Paid
            viewController.invoiceModel = item
            self.navigationController?.present(viewController, animated: true, completion: nil)
        }
    }
    
    override func getTableView() -> UITableView {
        return tabView
    }
    
    override func registerCells() {
        self.tabView.register(InvoiceTableViewCell.nib, forCellReuseIdentifier: InvoiceTableViewCell.identifier)
    }
    
    
    override func getNavBar() -> UINavigationBar? {
        return self.navigationController?.navigationBar
    }
    
    override func getTitle() -> String? {
        return R.string.localizable.tabBarInvoicesItemTitle()
    }
    
    override func getNavItem() -> UINavigationItem? {
        return self.navigationItem
    }
    
    override func refresh() {
        super.refresh()
        self.animate(isShow: false)
    }

    
    override func getTitleView() -> UIView {
        if let model = viewModel {
            return model.getTitleView()
        } else {
            return super.getTitleView()
        }
    }
    
    func hideMenu() {
        self.view.endEditing(true)
        self.tabView.reloadData()
        self.animate(isShow: false)
        if (self.navigationItem.titleView is BTNavigationDropdownMenu) {
            let menu = self.navigationItem.titleView as! BTNavigationDropdownMenu
            menu.hideMenu()
            if let items = self.state?.getMenuItems() {
                menu.updateItems(items)
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !textField.filterNumbers(with: string) {
            return false
        }
        if(textField == self.sumTextField) {
            if !self.sumTextField.textField(textField, shouldChangeCharactersIn: range, replacementString: string) {
                return false
            }
            
            if let text = self.sumTextField.getOldText(), let textNsString = text as? NSString {
            
                let newString = textNsString.replacingCharacters(in: range, with: string)
                
                if !(TextFieldUtil.validateMinValue(newString: newString, minValue:  0, range: range, replacementString: string, true, symbol: self.sumTextField.symbolValue)) {
                    return false
                }
                if let state = self.state, !(TextFieldUtil.validateMaxValue(newString: newString, maxValue: state.amount, range: range, replacementString: string, symbol: self.sumTextField.symbolValue)){
                    ViewUtils.shared.showToast(message: R.string.localizable.invoiceScreenErrorChangingAmount(), view: self.view)
                    return false
                
                }
            }
            
        }
        return true
    }
    
    func onItemSelected(isSelected: Bool, index: Int) {
        if !UserPreference.shared.isSuperviser() && !isDisabledValue {
            self.selectedItemTextField.text = self.state?.getSelectedString()
            self.loadView(isShowLoading: false, isHiddenSelected: true)
            Theme.shared.configureTextFieldCurrencyStyle(self.sumTextField)
            
            self.getAmount()
            self.initDownView(isSelected: isSelected)
        }
    }
    
    func reloadTable(jsonString: String!) {
        self.state?.mapping(jsonString: jsonString)
        if let count = state?.getItems().count {
            self.placeholderInvoice.isHidden = count != 0
        }
        self.tabView.reloadData()
        self.endRefreshAnimation(wasEmpty: false, dataFetched: true)
        
        if let count = state?.getItems().count, count > 0 {
            let indexPath = IndexPath(row: 0, section: 0)
            self.tabView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
    
    private func initDownView(isSelected: Bool) {
        if (isSelected && self.downViewHeightConstraint.constant == 0) {
            self.animate(isShow: true)
        } else if (!isSelected && self.downViewHeightConstraint.constant != 0 && self.state?.getCountSelected() == 0) {
            self.sumTextField.text = ""
            self.animate(isShow: false)
        }
    }
    
    // MARK: keyboard
    private func initKeyboardEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.bottomConstrain.constant = -keyboardSize.size.height/2 - 70
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.bottomConstrain.constant = 0
    }
    
}
