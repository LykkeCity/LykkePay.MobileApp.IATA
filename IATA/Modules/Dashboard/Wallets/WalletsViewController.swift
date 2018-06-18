
import UIKit

class WalletsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var totalBalanceLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!

    private var state: WalletsState = DefaultWalletsState() as WalletsState

    private var wallets: [WalletsModel] = []

    private var walletsViewModel: [WalletsViewModel] = []

    private var totalBalance: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(WalletsTableViewCell.nib, forCellReuseIdentifier: WalletsTableViewCell.identifier)
        tableView.tableFooterView = UIView(frame: .zero)
        walletsViewModel = state.generateTestWalletsData()
        totalBalance = state.getTotalBalance(from:walletsViewModel)
        //loadData()

    }
    //todo
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = Theme.shared.tabBarBackgroundColor
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "GothamPro-Medium", size: 17)]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = tabBarItem.title?.capitalizingFirstLetter()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return walletsViewModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WalletsTableViewCell.identifier) as?  WalletsTableViewCell else {
            return WalletsTableViewCell()
        }
        totalBalanceLabel.text = totalBalance
        cell.fillCell(from: walletsViewModel[indexPath.row])
        return cell
    }

    private func loadData() {
        self.state.getWalletsStringJson()
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
        self.wallets = state.mapping(jsonString: jsonString)
        self.tableView.reloadData()
    }
}
