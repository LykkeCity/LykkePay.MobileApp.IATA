
import UIKit


class WalletsViewController: BaseViewController<WalletsViewModel, DefaultWalletsState>, UINavigationControllerDelegate, WalletsCellClick {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var placeholderWallets: UIView!

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return PresentAnimation()
    }
    
    override func viewDidLoad() {
        state = DefaultWalletsState()
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        initViewTheme()
        initTableViewTheme()
        self.beginRefreshing()
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.delegate = self
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.state?.items.count {
            return count
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CustomHeaderView.identifier) as! CustomHeaderView
        headerView.balanceLabel.text = self.state?.getTotalBalance()
        if state?.getItems().count == 0 {
            return UIView()
        } else {
            return headerView
        }
    }
    
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WalletsTableViewCell.identifier) as?  WalletsTableViewCell else {
            return WalletsTableViewCell()
        }
        cell.delegate = self
        cell.selectionStyle = .none
        if let item = self.state?.getItems() [indexPath.row] {
            cell.fillCell(from: item)
        }
        return cell
    }

    override func loadData() {
        if let id = UserPreference.shared.getCurrentCurrency()?.id {
            self.state?.getWalletsStringJson(id: id)
                .then(execute: { [weak self] (result: String) -> Void in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.reloadTable(jsonString: result)
                })
                .catch(execute: { [weak self] error -> Void in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.generateErrorAlert(error: error)
                    strongSelf.endRefreshAnimation(wasEmpty: false, dataFetched: true)
                })
        }
    }

    private func reloadTable(jsonString: String!) {
        self.state?.mapping(jsonString: jsonString)
        if let count = state?.getItems().count {
            placeholderWallets.isHidden = count != 0
        }
        setVisibleViewAfterLoadingData()
        self.tableView.reloadData()
        self.endRefreshAnimation(wasEmpty: false, dataFetched: true)
    }

    override func getTitle() -> String? {
        return tabBarItem.title?.capitalizingFirstLetter()
    }

    override func getTableView() -> UITableView {
        return tableView
    }

    override func registerCells() {
         tableView.register(CustomHeaderView.nib, forHeaderFooterViewReuseIdentifier: CustomHeaderView.identifier)
        tableView.register(WalletsTableViewCell.nib, forCellReuseIdentifier: WalletsTableViewCell.identifier)
    }

    private func initViewTheme() {
        self.tableView.separatorColor = Theme.shared.dotColor
    }

    private func setVisibleViewAfterLoadingData() {
        self.tableView.isHidden = false
    }
    
    private func initTableViewTheme() {
        self.tableView.separatorColor = UIColor.clear
    }

    func bttnTapped(cell: WalletsTableViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        let viewController = CashInViewController()
        if let item = self.state?.getItems() [indexPath!.row] {
            viewController.totalSum = item.totalBalance
            viewController.assertId = item.assetId
        }
       
        self.navigationController?.pushViewController(viewController, animated: true)
       
    }
}
