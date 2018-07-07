import UIKit

class TransactionViewController: BaseViewController<PropertyKeyTransactionModel, DefaultTransactionState> {
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navView: UIView!
    @IBOutlet private weak var tabView: UITableView!
    @IBOutlet private weak var transactionHeaderView: TransactionTableViewHeader!
    
    var id = String()
    var invoiceId: String?
    
    override func viewDidLoad() {
        state = DefaultTransactionState()
        super.viewDidLoad()
        self.tabView.separatorStyle = .none
        self.navigationController?.isNavigationBarHidden = true
        self.loadData()
    }
    
    override func getNavItem() -> UINavigationItem? {
        return navItem
    }
    
    override func getNavBar() -> UINavigationBar? {
        return navBar
    }
    
    override func getNavView() -> UIView? {
        return navView
    }

    override func getLeftButton() -> UIBarButtonItem? {
        let backButton = Theme.shared.getCancel(title: R.string.localizable.commonNavBarClose(), color: UIColor.white)
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        return UIBarButtonItem(customView: backButton)
    }

    @objc func backButtonAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tabView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.identifier, for: indexPath) as! TransactionTableViewCell
        
        if let model = self.state?.getItems()[indexPath.row] {
            cell.initCell(model: model)
        }
        return cell
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
    
    override func loadData() {
        super.loadData()
        if let invoiceId = self.invoiceId {
            loadPayedHistoryDetails(invoiceId: invoiceId)
        } else {
            loadHistoryDetails()
        }
    }

    private func loadPayedHistoryDetails(invoiceId: String) {
        self.state?.getPayedHistoryDetails(invoiceId: invoiceId)
            .then(execute: { [weak self] (result: HistoryTransactionModel) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.reloadViews(item: result)
            }).catch(execute: { [weak self] error -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.handleError(strongSelf: strongSelf, error: error)
            })
    }

    private func loadHistoryDetails() {
        self.state?.getHistoryDetails(id: id)
            .then(execute: { [weak self] (result: HistoryTransactionModel) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.reloadViews(item: result)
            }).catch(execute: { [weak self] error -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.handleError(strongSelf: strongSelf, error: error)
            })
    }

    private func handleError(strongSelf: TransactionViewController, error: Error) {
        strongSelf.showErrorAlert(error: error)
        strongSelf.refreshControl.endRefreshing()
        strongSelf.tabView.reloadData()
    }

    private func reloadTable(item: HistoryTransactionModel) {
        self.state?.initItems(item: item)
        self.tabView.reloadData()
    }

    private func reloadViews(item: HistoryTransactionModel) {
        reloadTable(item: item)
        transactionHeaderView.model = item
        self.endRefreshAnimation(wasEmpty: false, dataFetched: true)
    }
}
