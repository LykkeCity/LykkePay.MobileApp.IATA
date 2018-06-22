import UIKit

class TransactionViewController: BaseViewController<PropertyKeyTransactionModel, DefaultTransactionState>, Initializer {
    
    @IBOutlet private weak var tabView: UITableView!
    @IBOutlet private weak var transactionHeaderView: TransactionTableViewHeader!
    
    var id = String()
    
    override func viewDidLoad() {
        initializer = self
        state = DefaultTransactionState()
        super.viewDidLoad()
        self.loadData()
    }

    override func getLeftButton() -> UIBarButtonItem? {

        let buttonImage = R.image.backIcon()?.stretchableImage(withLeftCapWidth: 0, topCapHeight: 10)

        return UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: #selector(backButtonAction))
    }

    @objc func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tabView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.identifier, for: indexPath) as! TransactionTableViewCell
        
        if let model = self.state?.getItems()[indexPath.row] {
            cell.initCell(model: model)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func getTitle() -> String? {
        return R.string.localizable.historyTransactionScreenTitle()
    }
    
    override func getTableView() -> UITableView {
        return tabView
    }
    
    override func registerCells() {
        self.tabView.register(TransactionTableViewCell.nib, forCellReuseIdentifier: TransactionTableViewCell.identifier)
    }
    
    private func loadData() {
        self.state?.getHistoryDetails(id: id)
            .withSpinner(in: view)
            .then(execute: { [weak self] (result: HistoryTransactionModel) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.reloadViews(item: result)
            })
    }
    
    private func reloadTable(item: HistoryTransactionModel) {
        self.state?.initItems(item: item)
        self.tabView.reloadData()
    }

    private func reloadViews(item: HistoryTransactionModel) {
        reloadTable(item: item)
        transactionHeaderView.model = item
    }
}
