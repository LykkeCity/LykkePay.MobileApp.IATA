import UIKit

class DisputeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var items: [String] = []
    
    @IBOutlet weak var tabView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabView.register(InvoiceTableViewCell.nib, forCellReuseIdentifier: InvoiceTableViewCell.identifier)
        self.tabView.delegate = self
        self.tabView.dataSource = self
        self.tabView.tableFooterView = UIView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DisputeTableViewCell.identifier, for: indexPath) as! DisputeTableViewCell
        
        return cell
    }

}
