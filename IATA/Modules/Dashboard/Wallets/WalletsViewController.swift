
import UIKit


class WalletsViewController: BaseViewController<WalletsViewModel, DefaultWalletsState> {

    @IBOutlet weak var totalBalanceLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!

    private let refreshControl = UIRefreshControl()


    override func viewDidLoad() {
        state = DefaultWalletsState()
        super.viewDidLoad()
        addRefreshControl()
        self.navigationController?.isNavigationBarHidden = false
        loadData()
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

    private func loadData() {
        if let id = UserPreference.shared.getCurrentCurrency()?.id {
            self.state?.getWalletsStringJson(id: id)
                .withSpinner(in: view)
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

    private func addRefreshControl() {
        refreshControl.attributedTitle = NSAttributedString(string: "loading...")
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
    }

    @objc func refresh() {
        loadData()
    }

    private func initTableViewTheme() {
        self.tableView.separatorColor = Theme.shared.dotColor
    }
}
