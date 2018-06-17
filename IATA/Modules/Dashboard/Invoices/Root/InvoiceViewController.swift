import UIKit
import ObjectMapper

class InvoiceViewController: BaseViewController<InvoiceModel, DefaultInvoiceState>,
    Initializer,
    UITextFieldDelegate,
    OnChangeStateSelected {
    
    @IBOutlet weak var tabView: UITableView!
    @IBOutlet weak var downView: UIView!
    @IBOutlet weak var sumTextField: DesignableUITextField!
    @IBOutlet weak var selectedItemTextField: UILabel!
    @IBOutlet weak var downViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        initializer = self
        state = DefaultInvoiceState()
        super.viewDidLoad()
        Theme.shared.configureTextFieldCurrencyStyle(self.sumTextField, title: "")
        self.downView.isHidden = true
        self.sumTextField.delegate = self
    }
    
    override func getLeftButton() -> UIBarButtonItem? {
        return UIBarButtonItem(image: UIImage(named: "ic_filter"), style: .plain, target: self, action: #selector(self.clickFilter(sender:)))
    }
    
    override func getRightButton() -> UIBarButtonItem? {
        return UIBarButtonItem(image: UIImage(named: "ic_dispute"), style: .plain, target: self, action: #selector(self.clickDispute(sender:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = self.tabView.cellForRow(at: indexPath) as! InvoiceTableViewCell
        if (currentCell.checkBox.isCanBeChanged) {
            currentCell.checkBox.isChecked = !currentCell.checkBox.isChecked
            onItemSelected(isSelected: currentCell.checkBox.isChecked, index: indexPath.row)
        }
    }
    
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
            let dispute = UITableViewRowAction(style: .normal, title: "Invoice.Screen.Items.Dispute".localize()) { (action, indexPath) in
                
            }
            
            dispute.backgroundColor = Theme.shared.pinkDisputeColor
            return [dispute]
        } else if (stateCanBeClosedDispute) {
            let dispute = UITableViewRowAction(style: .normal, title: "Invoice.Screen.Items.CancelDispute".localize()) { (action, indexPath) in
                
            }
            
            dispute.backgroundColor = Theme.shared.grayDisputeColor
            return [dispute]
        }
        return nil
    }
    
    func getTitle() -> String? {
        return "TabBar.InvoicesItem.Title".localize()
    }
    
    func getTableView() -> UITableView {
        return tabView
    }
    
    func registerCells() {
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
    
    func onItemSelected(isSelected: Bool, index: Int) {
        self.sumTextField.text = self.state?.getSumString(isSelected: isSelected, index: index)
        self.selectedItemTextField.text = self.state?.getSelectedString()
        if (isSelected && self.downView.isHidden) {
            animate(isShow: true)
        } else if (!isSelected && !self.downView.isHidden && self.state?.getCountSelected() == 0) {
           animate(isShow: false)
        }
    }
    
    private func animate(isShow: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.downView.alpha = isShow ? 1 : 0
        }
        self.downView.isHidden = isShow ? false : true
        self.downViewHeightConstraint.constant = isShow ? 110 : 0
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
            }).catch(execute: { [weak self] error -> Void in
                
            })
    }
    
    private func reloadTable(jsonString: String!) {
        self.state?.mapping(jsonString: jsonString)
        self.tabView.reloadData()
    }
    
    private func hideMenu() {
        self.state?.clearSelectedItems()
        self.animate(isShow: false)
        if (self.navigationItem.titleView is BTNavigationDropdownMenu) {
            let menu = self.navigationItem.titleView as! BTNavigationDropdownMenu
            menu.hideMenu()
        }
    }
}
