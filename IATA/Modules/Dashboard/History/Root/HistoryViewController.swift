import UIKit

class HistoryViewController: BaseViewController<HistoryModel, DefaultHistoryState>, Initializer {
    
    @IBOutlet weak var tabView: UITableView!
    
    override func viewDidLoad() {
        initializer = self
        state = DefaultHistoryState()
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HistoryTableViewCell.identifier, for: indexPath) as! HistoryTableViewCell
        
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
}
