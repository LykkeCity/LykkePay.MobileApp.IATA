
import UIKit


class WalletsViewController: BaseViewController<WalletsViewModel, DefaultWalletsState> , Initializer {

    @IBOutlet weak var totalBalanceLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!


    override func viewDidLoad() {
        initializer = self
        state = DefaultWalletsState()
        super.viewDidLoad()
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        totalBalanceLabel.text = state?.getTotalBalance()
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
        self.state?.getWalletsStringJson()
            .withSpinner(in: view)
            .then(execute: { [weak self] (result: String) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.reloadTable(jsonString: result)
            })
    }

    private func reloadTable(jsonString: String!) {
        self.state?.mapping(jsonString: jsonString)
        self.totalBalanceLabel.text = state?.getTotalBalance()
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
