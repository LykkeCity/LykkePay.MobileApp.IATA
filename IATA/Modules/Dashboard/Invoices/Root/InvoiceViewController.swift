import UIKit
import ObjectMapper

class InvoiceViewController: BaseViewController<InvoiceModel, DefaultInvoiceState>,
    Initializer,
OnChangeStateSelected {
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var sumTextFieldWidth: NSLayoutConstraint!
    @IBOutlet weak var tabView: UITableView!
    @IBOutlet weak var downView: UIView!
    @IBOutlet weak var sumTextField: DesignableUITextField!
    @IBOutlet weak var selectedItemTextField: UILabel!
    @IBOutlet weak var downViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstrain: NSLayoutConstraint!
    
    override func viewDidLoad() {
        initializer = self
        state = DefaultInvoiceState()
        super.viewDidLoad()
        Theme.shared.configureTextFieldCurrencyStyle(self.sumTextField)
        self.downView.isHidden = true
        self.sumTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func sumEditingEnd(_ sender: Any) {
        sumTextField.sizeToFit()
        self.sumTextFieldWidth.constant = sumTextField.frame.size.width
    }
    
    @IBAction func sumChanged(_ sender: Any) {
        sumTextField.sizeToFit()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.bottomConstrain.constant = -keyboardSize.size.height/2 - 20
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.bottomConstrain.constant = 0
    }
    
    override func getLeftButton() -> UIBarButtonItem? {
        return UIBarButtonItem(image: R.image.ic_filter(), style: .plain, target: self, action: #selector(self.clickFilter(sender:)))
    }
    
    override func getRightButton() -> UIBarButtonItem? {
        return UIBarButtonItem(image: R.image.ic_dispute(), style: .plain, target: self, action: #selector(self.clickDispute(sender:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideMenu()
        self.loadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InvoiceTableViewCell.identifier, for: indexPath) as! InvoiceTableViewCell
        cell.checkBox.tag = indexPath.row
        cell.delegate = self
        cell.selectionStyle = .none
        guard let dict = self.state?.getItems()[indexPath.row] else {
            return UITableViewCell()
        }
        guard let isChecked = self.state?.isChecked(model: dict) else {
            return UITableViewCell()
        }
        
        cell.initModel(model: dict, isChecked: isChecked)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
        }
    }
    
    /* Invoices are selected after tappinth the invoice, not radio button - qa asked
     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     let currentCell = self.tabView.cellForRow(at: indexPath) as! InvoiceTableViewCell
     if (currentCell.checkBox.isCanBeChanged) {
     currentCell.checkBox.isChecked = !currentCell.checkBox.isChecked
     onItemSelected(isSelected: currentCell.checkBox.isChecked, index: indexPath.row)
     }
     }*/
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let state = self.state else {
            return false
        }
        let stateCanBeOpenDispute = state.isCanBeOpenDispute(index: indexPath.row)
        let stateCanBeClosedDispute = state.isCanBeClosedDispute(index: indexPath.row)
        
        if (stateCanBeOpenDispute || stateCanBeClosedDispute) {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let state = self.state else {
            return nil
        }
        
        let stateCanBeOpenDispute = state.isCanBeOpenDispute(index: indexPath.row)
        let stateCanBeClosedDispute = state.isCanBeClosedDispute(index: indexPath.row)
        
        if (stateCanBeOpenDispute) {
            let dispute = UITableViewRowAction(style: .normal, title: R.string.localizable.invoiceScreenItemsDispute()) { (action, indexPath) in
                
            }
            
            dispute.backgroundColor = Theme.shared.pinkDisputeColor
            return [dispute]
        } else if (stateCanBeClosedDispute) {
            let dispute = UITableViewRowAction(style: .normal, title: R.string.localizable.invoiceScreenItemsCancelDispute()) { (action, indexPath) in
                
            }
            
            dispute.backgroundColor = Theme.shared.grayDisputeColor
            return [dispute]
        }
        return nil
    }
    
    override func getTitle() -> String? {
        return R.string.localizable.tabBarInvoicesItemTitle()
    }
    
    override func getTableView() -> UITableView {
        return tabView
    }
    
    override func registerCells() {
        self.tabView.register(InvoiceTableViewCell.nib, forCellReuseIdentifier: InvoiceTableViewCell.identifier)
    }
    
    @objc func clickFilter(sender: Any?) {
        self.navigationController?.pushViewController(InvoiceSettingsViewController(), animated: true)
        self.hideMenu()
    }
    
    @objc func clickDispute(sender: Any?) {
        self.navigationController?.pushViewController(DisputeViewController(), animated: true)
        self.hideMenu()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == self.sumTextField) {
            return TextFieldUtil.validateMaxValue(textField: textField, maxValue: self.state!.resultAmount(), range: range, replacementString: string)
        }
        return true
    }
    
    func getWidth(text: String) -> CGFloat {
        sumTextField.text = text
        sumTextField.sizeToFit()
        return sumTextField.frame.size.width
    }
    
    
    func onItemSelected(isSelected: Bool, index: Int) {
        self.sumTextField.text = self.state?.getSumString(isSelected: isSelected, index: index)
        self.selectedItemTextField.text = self.state?.getSelectedString()
        self.state?.getAmount()
            .then(execute: { [weak self] (result:PaymentAmount) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.saveAmount(amount: result.amountToPay)
            })
        self.sumEditingEnd(self.sumTextField)
        if (isSelected && self.downView.isHidden) {
            animate(isShow: true)
        } else if (!isSelected && !self.downView.isHidden && self.state?.getCountSelected() == 0) {
            animate(isShow: false)
        }
    }
    
    func makePayment(alert: UIAlertAction!) {
        self.state?.makePayment()
            .withSpinner(in: view)
            .then(execute: { [weak self] (result:Void) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.paymentSuccess()
            })
    }
    
    func paymentSuccess() {
        self.showToast(message: R.string.localizable.commonSuccessMessage())
        self.hideMenu()
    }
    
    @IBAction func makePay(_ sender: Any) {
        guard let amount = self.state?.amount else {
            return
        }
        
        guard let symbol = UserPreference.shared.getCurrentCurrency()?.symbol else {
            return
        }
        let message = R.string.localizable.invoiceScreenPaymentMessage(symbol + String(amount))
        let uiAlert = UIAlertController(title: R.string.localizable.invoiceScreenPleaseConfirmPayment(), message: message, preferredStyle: UIAlertControllerStyle.alert)
        self.present(uiAlert, animated: true, completion: nil)
        
        uiAlert.addAction(UIAlertAction(title: R.string.localizable.commonNavBarCancel(), style: .default, handler: nil))
        uiAlert.addAction(UIAlertAction(title: R.string.localizable.invoiceScreenPay(), style: .default, handler: makePayment))
        
    }
    
    private func saveAmount(amount: Int?) {
        if let amountValue = amount {
            self.state?.amount = amountValue
            self.sumTextField.text = String(amountValue)
        }
        self.selectedItemTextField.isHidden = false
        self.sumTextField.isHidden = false
        self.loading.isHidden = true
    }
    
    private func initWidth() {
        let width = getWidth(text: sumTextField.text!)
        sumTextFieldWidth.constant = 0.0
        if width > sumTextFieldWidth.constant {
            sumTextFieldWidth.constant = width
        }
        self.view.layoutIfNeeded()
    }
    
    private func animate(isShow: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.downView.alpha = isShow ? 1 : 0
        }
        self.downView.isHidden = isShow ? false : true
        self.downViewHeightConstraint.constant = isShow ? 110 : 0
        self.loading.isHidden = false
        self.sumTextField.isHidden = true
        self.selectedItemTextField.isHidden = true
        self.loading.startAnimating()
    }
    
    override func getTitleView() -> UIView {
        guard let state = self.state else {
            return Theme.shared.getTitle(title: getTitle(), color: UIColor.white)
        }
        let menuView = BTNavigationDropdownMenu(title: BTTitle.index(FilterPreference.shared.getIndexOfStatus()), items: state.getMenuItems())
        menuView.backgroundColor = Theme.shared.tabBarBackgroundColor
        menuView.cellBackgroundColor = Theme.shared.tabBarBackgroundColor
        menuView.cellTextLabelColor = UIColor.white
        menuView.cellSeparatorColor = UIColor.clear
        menuView.menuTitleColor = UIColor.white
        menuView.cellSelectionColor = Theme.shared.tabBarBackgroundColor
        menuView.selectedCellTextLabelColor = Theme.shared.tabBarItemSelectedColor
        menuView.didSelectItemAtIndexHandler = {[weak self] (indexPath: Int) -> () in
            FilterPreference.shared.saveIndexOfStatus(indexPath)
            self?.state?.selectedStatus(index: indexPath)
            self?.hideMenu()
            self?.loadData()
        }
        return menuView
    }
    
    private func loadData() {
        self.state?.getInvoiceStringJson()
            .withSpinner(in: view)
            .then(execute: { [weak self] (result: String) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.reloadTable(jsonString: result)
            })
    }
    
    private func reloadTable(jsonString: String!) {
        self.state?.mapping(jsonString: jsonString)
        self.tabView.reloadData()
    }
    
    private func hideMenu() {
        self.view.endEditing(true)
        self.tabView.reloadData()
        self.state?.clearSelectedItems()
        self.animate(isShow: false)
        if (self.navigationItem.titleView is BTNavigationDropdownMenu) {
            let menu = self.navigationItem.titleView as! BTNavigationDropdownMenu
            menu.hideMenu()
        }
    }
    
}
