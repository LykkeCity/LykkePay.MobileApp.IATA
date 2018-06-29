
import UIKit


class WalletsViewController: BaseViewController<WalletsViewModel, DefaultWalletsState> {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var placeholderWallets: UIView!

    override func viewDidLoad() {
        state = DefaultWalletsState()
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        initViewTheme()
        initTableViewTheme()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        loadData()
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
        cell.fillCell(from: (self.state?.getItems() [indexPath.row])!)
        return cell
    }

    override func loadData() {
        super.loadData()
        if let id = UserPreference.shared.getCurrentCurrency()?.id {
            self.state?.getWalletsStringJson(id: id)
                .then(execute: { [weak self] (result: String) -> Void in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.reloadTable(jsonString: result)
                })
        }
    }

    private func reloadTable(jsonString: String!) {
        self.state?.mapping(jsonString: jsonString)
        if (state?.getItems().count)! == 0 {
            placeholderWallets.isHidden = false
        }
        setVisibleViewAfterLoadingData()
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
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
        self.tableView.separatorColor = Theme.shared.dotColor
    }
}
