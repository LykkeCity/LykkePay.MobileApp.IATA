import UIKit
import ObjectMapper


class InvoiceViewController: BaseViewController<InvoiceModel, DefaultInvoiceState>, OnChangeStateSelected, SwipeTableViewCellDelegate {

   
    @IBOutlet weak var sumTextField: CurrencyUiTextField!
    @IBOutlet weak var btnPay: UIButton!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var tabView: UITableView!
    @IBOutlet weak var downView: UIView!
    @IBOutlet weak var selectedItemTextField: UILabel!
    @IBOutlet weak var downViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstrain: NSLayoutConstraint!

    @IBOutlet weak var placeholderInvoice: UIView!

    override func viewDidLoad() {
        state = DefaultInvoiceState()
        super.viewDidLoad()
        loadData()
        self.sumTextField.delegate = self
        self.sumTextField.addObservers()
        
        self.navigationController?.isNavigationBarHidden = false
        Theme.shared.configureTextFieldCurrencyStyle(self.sumTextField)
        self.downViewHeightConstraint.constant = 0
        self.downView.isHidden = true
        
        self.initKeyboardEvents()

        //better use protocol - will rewrite later
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: "loadData"), object: nil)
    }
    
    @IBAction func makePay(_ sender: Any) {
        guard let amount = self.state?.amount else {
            return
        }
        
        guard let symbol = UserPreference.shared.getCurrentCurrency()?.symbol else {
            return
        }
        let message = R.string.localizable.invoiceScreenPaymentMessage(symbol + String(amount))
        generatePaymentAlert(message: message, handler: makePayment)

    }
    
    @IBAction func sumChanged(_ sender: Any) {
        if let text = self.sumTextField.text, let isEmpty = self.sumTextField.text?.isEmpty, isEmpty || (Int(text) == 0) {
            self.sumTextField.text = "0"
            setEnabledPay(isEnabled: false)
        } else if let text = self.sumTextField.text {
            var valueString = text
            if text.starts(with: "0") && !text.starts(with: "0.") {
                let fromIndex = text.index(text.startIndex, offsetBy: 1)
                valueString = text.substring(from: fromIndex)
                self.sumTextField.text = valueString
            }
            setEnabledPay(isEnabled: true)
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: InvoiceTableViewCell.identifier, for: indexPath) as! InvoiceTableViewCell
        cell.checkBox.tag = indexPath.row
        cell.delegateChanged = self
        cell.delegate = self
        guard let dict = self.state?.getItems()[indexPath.row] else {
            return UITableViewCell()
        }
        guard let isChecked = self.state?.isChecked(model: dict) else {
            return UITableViewCell()
        }
        
        cell.initModel(model: dict, isChecked: isChecked)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        guard let state = self.state else {
            return nil
        }
        
        let stateCanBeOpenDispute = state.isCanBeOpenDispute(index: indexPath.row)
        let stateCanBeClosedDispute = state.isCanBeClosedDispute(index: indexPath.row)
        
        if (stateCanBeOpenDispute) {
            let disputeAction = SwipeAction(style: .destructive, title: R.string.localizable.invoiceScreenItemsDispute()) { action, indexPath in
                let disputInvoiceVC = DisputInvoiceViewController()
                disputInvoiceVC.completion = {
                    self.loadData()
                }
                disputInvoiceVC.invoiceId = state.getItems()[indexPath.row].id
                self.present(disputInvoiceVC, animated: true, completion: nil)
            }
            return getTableAction(Theme.shared.pinkDisputeColor,  disputeAction, 80)
            
        } else if (stateCanBeClosedDispute) {
            let disputeAction = SwipeAction(style: .destructive, title: R.string.localizable.invoiceScreenItemsCancelDispute()) { action, indexPath in
                let model = CancelDisputInvoiceRequest()
                model?.invoiceId = state.getItems()[indexPath.row].id
                if let model = model {
                    self.state?.cancelDisputInvoice(model: model)
                        .withSpinner(in: self.view)
                        .then(execute: { [weak self] (result: Void) -> Void in
                            guard let strongSelf = self else {
                                return
                            }
                            strongSelf.loadData()
                        })
                }
            }
        
            return getTableAction(Theme.shared.grayDisputeColor, disputeAction, 140)
            
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
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
        let viewController = InvoiceSettingsViewController()
        viewController.setNeedsStatusBarAppearanceUpdate()
        viewController.completion = {
            self.loadData()
        }
        self.navigationController?.present(viewController, animated: true, completion: nil)
        self.hideMenu()
    }
    
    @objc func clickDispute(sender: Any?) {
        self.navigationController?.present(DisputeViewController(), animated: true, completion: nil)
        self.hideMenu()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == self.sumTextField) {
            
            if let text = self.sumTextField.getOldText(), let textNsString = text as? NSString {
            
                let newString = textNsString.replacingCharacters(in: range, with: string)
                if let text = self.sumTextField.text, text.contains("."), string.elementsEqual(".") {
                    return false
                }
                
                if let indexOf = newString.index(of: ".") {
                    let valueString = newString.substring(from: indexOf)
                    
                    if valueString.characters.count > 6 {
                        return false
                    }
                }
                
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
        self.state?.newItem(isSelected: isSelected, index: index)
        self.selectedItemTextField.text = self.state?.getSelectedString()
        self.loadView(isShowLoading: false, isHiddenSelected: true)
        Theme.shared.configureTextFieldCurrencyStyle(self.sumTextField)
        self.state?.getAmount()
            .then(execute: { [weak self] (result: PaymentAmount) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.saveAmount(amount: result.amountToPay)
            }).catch(execute: { [weak self] error -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.handleError(error: error)
            })
        if (isSelected && self.downViewHeightConstraint.constant == 0) {
            animate(isShow: true)
        } else if (!isSelected && self.downViewHeightConstraint.constant != 0 && self.state?.getCountSelected() == 0) {
            self.sumTextField.text = ""
            animate(isShow: false)
        }
    }
    
    func makePayment(alert: UIAlertAction!) {
        let viewController = PinViewController()
        viewController.isValidationTransaction = true
        let items = self.state?.getItemsId()
        viewController.completion = {
            self.state?.makePayment(items: items)
                .then(execute: {[weak self] (result: BaseMappable) -> Void in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.paymentSuccess()
                }).catch(execute: { [weak self] error -> Void in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.handleError(error: error)
                })
        }
        self.navigationController?.present(viewController, animated: true, completion: nil)

    }
    
    func paymentSuccess() {
        ViewUtils.shared.showToast(message: R.string.localizable.commonSuccessMessage(), view: self.view)
        self.loadData()
        self.hideMenu()
    }
    
    private func setEnabledPay(isEnabled: Bool) {
        self.btnPay.isEnabled = isEnabled
        self.btnPay.alpha = isEnabled ? 1 : 0.2
        self.sumTextField.alpha = isEnabled ? 1 : 0.2
    }
    
    private func getTableAction(_ backgroundColor: UIColor, _ action: SwipeAction,_ width: Int) -> [SwipeAction] {
        action.width = width
        action.image = UIView.from(color: backgroundColor)
        action.backgroundColor = UIColor.white
        action.font = Theme.shared.boldFontOfSize(14)
        
        return [action]
    }
    
    private func handleError(error : Error) {
        self.showErrorAlert(error: error)
        self.animate(isShow: false)
        self.tabView.reloadData()
    }

    
    private func saveAmount(amount: Double?) {
        if let amountValue = amount, self.downViewHeightConstraint.constant != 0 {
            self.state?.amount = Double(amountValue)
            self.sumTextField.text = String(amountValue)
        }
        self.sumChanged(self.sumTextField)
        self.loadView(isShowLoading: true, isHiddenSelected: false)
    }
    
    private func loadView(isShowLoading: Bool, isHiddenSelected: Bool) {
        self.loading.isHidden = isShowLoading
        self.sumTextField.isHidden = isHiddenSelected
        self.selectedItemTextField.isHidden = isHiddenSelected
        isHiddenSelected ? self.loading.startAnimating() : self.loading.stopAnimating()
        setEnabledPay(isEnabled: isShowLoading)
    }
    
    private func initKeyboardEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    private func animate(isShow: Bool) {
        UIView.animate(withDuration: 0.5 , animations: {
            if isShow {
                self.downView.isHidden = !isShow
            }
            self.downView.alpha = isShow ? 1 : 0
            self.downViewHeightConstraint.constant = isShow ? 90 : 0
            self.downView.layoutIfNeeded()
        }, completion: {(finished) in
            if !isShow {
                self.downView.isHidden = isShow
            }
        })
        view.endEditing(!isShow)
        if !isShow {
            self.state?.clearSelectedItems()
        }

        self.loadView(isShowLoading: false, isHiddenSelected: true)
    }
    
    override func getNavBar() -> UINavigationBar? {
        return self.navigationController?.navigationBar
    }
 
    override func getNavItem() -> UINavigationItem? {
        return self.navigationItem
    }
    
    override func getTitleView() -> UIView {
        guard let state = self.state, let index = self.state?.getIndex() else {
            return Theme.shared.getTitle(title: getTitle(), color: UIColor.white)
        }
        self.state?.initSelected()
        let menuView = BTNavigationDropdownMenu(index: index, items: state.getMenuItems())
        menuView.backgroundColor = Theme.shared.tabBarBackgroundColor
        menuView.cellBackgroundColor = Theme.shared.tabBarBackgroundColor
        menuView.cellTextLabelColor = UIColor.white
        menuView.cellSeparatorColor = UIColor.clear
        menuView.menuTitleColor = UIColor.white
        menuView.cellSelectionColor = Theme.shared.tabBarBackgroundColor
        menuView.selectedCellTextLabelColor = Theme.shared.tabBarItemSelectedColor
        menuView.didSelectItemAtIndexHandler = {[weak self] (menu: Menu) -> () in
            FilterPreference.shared.saveIndexOfStatus(menu.type)
            self?.state?.selectedStatus(type: menu.type)
            self?.hideMenu()
            menuView.title = menu.title
            self?.loadData()
        }
        return menuView
    }
    
     override func loadData() {
        super.loadData()
        self.state?.getInvoiceStringJson()
            .then(execute: { [weak self] (result: String) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.reloadTable(jsonString: result)
            })
    }
    
    private func reloadTable(jsonString: String!) {
        self.state?.mapping(jsonString: jsonString)
        if (state?.getItems().count)! == 0 {
            placeholderInvoice.isHidden = false
        }
        self.tabView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    private func hideMenu() {
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
}
