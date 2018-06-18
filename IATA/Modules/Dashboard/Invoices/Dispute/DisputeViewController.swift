import UIKit

class DisputeViewController: BaseViewController<DisputeModel, DefaultDisputeState>, Initializer {
    
    @IBOutlet weak var tabView: UITableView!
    
    override func viewDidLoad() {
        initializer = self
        state = DefaultDisputeState()
        super.viewDidLoad()
        self.tabView.rowHeight = UITableViewAutomaticDimension
        self.tabView.estimatedRowHeight = 200
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DisputeTableViewCell.identifier, for: indexPath) as? DisputeTableViewCell else {
            return UITableViewCell()
        }
        
        guard let model = self.state?.getItems()[indexPath.row] else {
            return UITableViewCell()
        }
        cell.initCell(model: model)
        return cell
    }
    
    func getTitle() -> String? {
        return "Invoice.Dispute.Title".localize()
    }
    
    func getTableView() -> UITableView {
        return tabView
    }
    
    func registerCells() {
        self.getTableView().register(DisputeTableViewCell.nib, forCellReuseIdentifier: DisputeTableViewCell.identifier)
    }

}
