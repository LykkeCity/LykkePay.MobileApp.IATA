import UIKit

class InvoiceViewController: UIViewController,
    UITableViewDelegate,
    UITableViewDataSource,
    OnChangeStateSelected{
    
    @IBOutlet weak var tabView: UITableView!
    @IBOutlet weak var downView: UIView!
    
    let items = ["Invoice.Navigation.Filtering.Title.AllInvoices".localize(), "Invoice.Navigation.Filtering.Title.UnPaidInvoices".localize(), "Invoice.Navigation.Filtering.Title.Dispute".localize()]
    
    var usersArray : Array = [["first_name": "michael", "last_name": "jackson"], ["first_name" : "bill", "last_name" : "gates"], ["first_name" : "steve", "last_name" : "jobs"], ["first_name" : "mark", "last_name" : "zuckerberg"], ["first_name" : "anthony", "last_name" : "quinn"]]
    
    fileprivate func initMenu() {
        let menuView = BTNavigationDropdownMenu(title: BTTitle.index(1), items: items)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib.init(nibName: "InvoiceTableViewCell", bundle: nil)
        self.tabView.register(nib, forCellReuseIdentifier: "InvoiceTableViewCell")
        self.tabView.delegate = self
        self.tabView.dataSource = self
        
        downView.isHidden = true
        initMenu()
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
    
    
    // MARK: - UITableView delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InvoiceTableViewCell", for: indexPath) as! InvoiceTableViewCell
        cell.delegate = self
        cell.selectionStyle = .none
        let dict = usersArray[indexPath.row]
        
        
        return cell
    }
    
    
    func onItemSelected(isSelected: Bool, index: Int32) {
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
    }
}
