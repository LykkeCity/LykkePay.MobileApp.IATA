
import UIKit


class WalletsViewController: BaseViewController<WalletsViewModel, DefaultWalletsState> {

    @IBOutlet weak var totalBalanceLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!


    @IBOutlet weak var topView: UIView!

    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBOutlet weak var topSeparatorView: UIView!

    override func viewDidLoad() {
        state = DefaultWalletsState()
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        loadData()
        initViewTheme()
        initTableViewTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        totalBalanceLabel.text = state?.getTotalBalance()
        loadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.state?.items.count {
            return count
        } else {
            return 0
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
        self.totalBalanceLabel.text = state?.getTotalBalance()
        self.refreshControl.endRefreshing()
        self.tableView.reloadData()
        setVisibleViewAfterLoadingData()
    }

    override func getTitle() -> String? {
        return tabBarItem.title?.capitalizingFirstLetter()
    }

    override func getTableView() -> UITableView {
        return tableView
    }

    override func registerCells() {
        tableView.register(WalletsTableViewCell.nib, forCellReuseIdentifier: WalletsTableViewCell.identifier)
    }

    private func initViewTheme() {
        self.topView.isHidden = true
        self.logoImageView.isHidden = true
        self.topSeparatorView.isHidden = true
        self.tableView.separatorColor = Theme.shared.dotColor
    }

    private func setVisibleViewAfterLoadingData() {
        self.topView.isHidden = false
        self.logoImageView.isHidden = false
        self.topSeparatorView.isHidden = false
    }
    
    private func initTableViewTheme() {
        self.tableView.separatorColor = Theme.shared.dotColor
    }
}
