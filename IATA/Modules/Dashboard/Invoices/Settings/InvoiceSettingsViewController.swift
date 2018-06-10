import UIKit

class InvoiceSettingsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate let viewModel = InvoiceViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView?.dataSource = viewModel
        self.tableView?.delegate = viewModel
        
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.estimatedRowHeight = 55
        
        
        let headerNib = UINib.init(nibName: "InvoiceHeaderView", bundle: Bundle.main)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "InvoiceHeaderView")
        
        tableView?.register(PaymentRangeTableViewCell.nib, forCellReuseIdentifier: PaymentRangeTableViewCell.identifier)
        tableView?.register(SimpleTableViewCell.nib, forCellReuseIdentifier: SimpleTableViewCell.identifier)
        tableView?.register(AirlinesTableViewCell.nib, forCellReuseIdentifier: AirlinesTableViewCell.identifier)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let backItem = UIBarButtonItem(title: "Cancel", style: .bordered, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backItem
    }
}
