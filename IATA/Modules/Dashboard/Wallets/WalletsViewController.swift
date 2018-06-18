
import UIKit

class WalletsViewController: BaseViewController<WalletsModel, DefaultWalletsState> , Initializer {

    @IBOutlet weak var totalBalanceLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!

    private var wallets: [WalletsModel] = []

    private var walletsViewModel: [WalletsViewModel] = []

    private var totalBalance: String?

    override func viewDidLoad() {
        initializer = self
        state = DefaultWalletsState()
        super.viewDidLoad()
        loadData()
        if let testData = state?.generateTestWalletsData() {
            walletsViewModel = testData
        }
        totalBalance = state?.getTotalBalance(from:walletsViewModel)
    }
    //todo
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return walletsViewModel.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WalletsTableViewCell.identifier) as?  WalletsTableViewCell else {
            return WalletsTableViewCell()
        }
        totalBalanceLabel.text = totalBalance
        cell.fillCell(from: walletsViewModel[indexPath.row])
        return cell
    }

    private func loadData() {
        self.state?.getWalletsStringJson()
            .withSpinner(in: view)
            .then(execute: { [weak self] (result: String) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.reloadTable(jsonString: result)
            }).catch(execute: { [weak self] error -> Void in

            })
    }

    private func reloadTable(jsonString: String!) {
        self.wallets = (state?.mapping(jsonString: jsonString))!
        self.tableView.reloadData()
    }

    func getTitle() -> String? {
        return tabBarItem.title?.capitalizingFirstLetter()
    }

    func getTableView() -> UITableView {
        return tableView
    }

    func registerCells() {
        tableView.register(WalletsTableViewCell.nib, forCellReuseIdentifier: WalletsTableViewCell.identifier)
    }
}
