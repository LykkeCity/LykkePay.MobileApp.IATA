import UIKit
import ObjectMapper

class InvoiceViewController: UIViewController,
    UITableViewDelegate,
    UITableViewDataSource,
    UITextFieldDelegate,
    OnChangeStateSelected {
    
    @IBOutlet weak var tabView: UITableView!
    @IBOutlet weak var downView: UIView!
    @IBOutlet weak var sumTextField: DesignableUITextField!
    
    private var state: InvoiceState = DefaultInvoiceState() as InvoiceState
    private var invoices = [InvoiceModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabView.register(InvoiceTableViewCell.nib, forCellReuseIdentifier: InvoiceTableViewCell.identifier)
        self.tabView.delegate = self
        self.tabView.dataSource = self
       
        Theme.shared.configureTextFieldCurrencyStyle(self.sumTextField)
        self.downView.isHidden = true
        self.sumTextField.delegate = self
        
        initMenu()
        self.state.getInvoiceStringJson()
            .withSpinner(in: view)
            .then(execute: { [weak self] (result: String) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.reloadTable(jsonString: result)
            }).catch(execute: { [weak self] error -> Void in
                guard let strongSelf = self else {
                    return
                }
            })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = Theme.shared.tabBarBackgroundColor
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.navigationItem.leftBarButtonItem  = UIBarButtonItem(image: UIImage(named: "ic_filter"), style: .plain, target: self, action: #selector(self.clickFilter(sender:)))
    }
    
    @objc func clickFilter(sender: Any?) {
        self.navigationController?.pushViewController(InvoiceSettingsViewController(), animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invoices.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InvoiceTableViewCell.identifier, for: indexPath) as! InvoiceTableViewCell
        cell.checkBox.tag = indexPath.row
        cell.delegate = self
        cell.selectionStyle = .none
        let dict = invoices[indexPath.row]
        
        cell.labelName.text = dict.clientName
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
           
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let dispute = UITableViewRowAction(style: .normal, title: "dispute") { (action, indexPath) in
            // share item at indexPath
        }
        
        dispute.backgroundColor = UIColor.blue
        
        return [dispute]
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(textField == self.sumTextField) {
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            
            return TextFieldUtil.validateMaxValue(textField: textField, maxValue: self.state.resultAmount(), range: range, replacementString: string)
        }
        return true
    }
    
    func onItemSelected(isSelected: Bool, index: Int) {
        if (isSelected && downView.isHidden) {
            downView.alpha = 0
            downView.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.downView.alpha = 1
            }
        } else if (!isSelected && !downView.isHidden) {
            UIView.animate(withDuration: 0.3, animations: {
                self.downView.alpha = 0
            }) { (finished) in
                self.downView.isHidden = finished
            }
        }
        
        self.sumTextField.text = String(self.state.recalculateAmount(isSelected: isSelected, model: self.invoices[index]))
    }
    
    private func initMenu() {
        let menuView = BTNavigationDropdownMenu(title: BTTitle.index(1), items: state.getMenuItems())
        menuView.backgroundColor = Theme.shared.tabBarBackgroundColor
        menuView.cellBackgroundColor = Theme.shared.tabBarBackgroundColor
        menuView.cellTextLabelColor = UIColor.white
        menuView.cellSeparatorColor = UIColor.clear
        menuView.menuTitleColor = UIColor.white
        menuView.cellSelectionColor = Theme.shared.tabBarBackgroundColor
        menuView.selectedCellTextLabelColor = Theme.shared.tabBarItemSelectedColor
        menuView.didSelectItemAtIndexHandler = {[weak self] (indexPath: Int) -> () in
            //self.items.text = items[indexPath]
        }
        self.navigationItem.titleView = menuView
    }
    
    private func reloadTable(jsonString: String!) {
        self.invoices = state.mapping(jsonString: jsonString)
        self.tabView.reloadData()
    }
}
