import UIKit

class HistoryViewController: BaseViewController<HistoryModel, DefaultHistoryState> {
    
    @IBOutlet weak var tabView: UITableView!
    
    @IBOutlet weak var placeholderHistory: UIView!
    
    override func viewDidLoad() {
        state = DefaultHistoryState()
        super.viewDidLoad()
        self.tabView.separatorStyle = .none
        self.navigationController?.isNavigationBarHidden = false
        self.loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HistoryTableViewCell.identifier, for: indexPath) as! HistoryTableViewCell
        cell.selectionStyle = .none
        guard let model = self.state?.getItems()[indexPath.row] else {
            return UITableViewCell()
        }
        cell.initCell(model: model)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = TransactionViewController()
        if let id = self.state?.getItems()[indexPath.row].id {
            viewController.id = id
        }
        self.navigationController?.present(viewController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func getTitle() -> String? {
        return R.string.localizable.historyScreenTitle()
    }
    
    override func getTableView() -> UITableView {
        return tabView
    }
    
    override func registerCells() {
        self.getTableView().register(HistoryTableViewCell.nib, forCellReuseIdentifier: HistoryTableViewCell.identifier)
    }
    
    override func loadData() {
        super.loadData()
        self.state?.getHistory()
            .then(execute: { [weak self] (result: String) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.reloadTable(jsonString: result)
            }).catch(execute: { [weak self] error -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.generateErrorAlert(error: error)
                strongSelf.refreshControl.endRefreshing()
            })
    }
    
    private func reloadTable(jsonString: String) {
        self.state?.mapping(jsonString: jsonString)
        if (state?.getItems().count)! == 0 {
            placeholderHistory.isHidden = false
        }
        self.tabView.reloadData()
        self.refreshControl.endRefreshing()
    }
}
