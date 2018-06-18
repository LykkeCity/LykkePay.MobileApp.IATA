
import UIKit

class WalletsViewController: BaseViewController<WalletsModel, DefaultWalletsState> , Initializer {

    @IBOutlet weak var totalBalanceLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!

    private var walletsViewModel: [WalletsViewModel] = []

    override func viewDidLoad() {
        initializer = self
        state = DefaultWalletsState()
        super.viewDidLoad()
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        totalBalanceLabel.text = state?.getTotalBalance(from:walletsViewModel)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return walletsViewModel.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WalletsTableViewCell.identifier) as?  WalletsTableViewCell else {
            return WalletsTableViewCell()
        }
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
        self.walletsViewModel = (state?.mapping(jsonString: jsonString))!
        totalBalanceLabel.text = state?.getTotalBalance(from:walletsViewModel)
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
