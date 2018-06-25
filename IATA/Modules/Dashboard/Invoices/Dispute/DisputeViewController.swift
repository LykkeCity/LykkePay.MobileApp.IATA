import UIKit

class DisputeViewController: BaseViewController<DisputeModel, DefaultDisputeState>, Initializer {
    
    @IBOutlet weak var tabView: UITableView!
    
    override func viewDidLoad() {
        initializer = self
        state = DefaultDisputeState()
        super.viewDidLoad()
        self.tabView.rowHeight = UITableViewAutomaticDimension
        self.tabView.estimatedRowHeight = 200
        loadData()
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

    private func loadData() {
        self.state?.getDisputeListStringJson()
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
    
    func getTitle() -> String? {
        return R.string.localizable.invoiceDisputeTitle()
    }
    
    func getTableView() -> UITableView {
        return tabView
    }
    
    func registerCells() {
        self.getTableView().register(DisputeTableViewCell.nib, forCellReuseIdentifier: DisputeTableViewCell.identifier)
    }

}
