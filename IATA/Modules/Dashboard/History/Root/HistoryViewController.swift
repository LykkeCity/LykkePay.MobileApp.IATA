import UIKit

class HistoryViewController: BaseViewController<HistoryModel, DefaultHistoryState>, Initializer {
    
    @IBOutlet weak var tabView: UITableView!
    
    override func viewDidLoad() {
        initializer = self
        state = DefaultHistoryState()
        super.viewDidLoad()
        self.loadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HistoryTableViewCell.identifier, for: indexPath) as! HistoryTableViewCell
        
        guard let model = self.state?.getItems()[indexPath.row] else {
            return UITableViewCell()
        }
        cell.initCell(model: model)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.pushViewController(TransactionViewController(), animated: true)
    }
    
    func getTitle() -> String? {
        return "History.Screen.Title".localize()
    }
    
    func getTableView() -> UITableView {
        return tabView
    }
    
    func registerCells() {
        self.getTableView().register(HistoryTableViewCell.nib, forCellReuseIdentifier: HistoryTableViewCell.identifier)
    }
    
    private func loadData() {
        self.state?.getHistory()
            .withSpinner(in: view)
            .then(execute: { [weak self] (result: String) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.reloadTable(jsonString: result)
            })
    }
    
    private func reloadTable(jsonString: String) {
        self.state?.mapping(jsonString: jsonString)
        self.tabView.reloadData()
    }
}
