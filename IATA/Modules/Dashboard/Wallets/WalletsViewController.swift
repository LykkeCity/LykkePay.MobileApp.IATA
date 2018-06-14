
import UIKit

class WalletsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var totalBalanceLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!

    private var testData = ["IATA USD", "IATA USD", "IATA USD"]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(WalletsTableViewCell.nib, forCellReuseIdentifier: WalletsTableViewCell.identifier)
        tableView.tableFooterView = UIView(frame: .zero)
    }
    //todo
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = Theme.shared.tabBarBackgroundColor
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = tabBarItem.title
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WalletsTableViewCell.identifier) as?  WalletsTableViewCell else {
            return WalletsTableViewCell()
        }
        totalBalanceLabel.text = "123,234.61 $"
        cell.balanceLabel.text = "1231231 $"
        cell.walletsNameLabel.text = testData[indexPath.row]
        cell.nationalFlagImage.image = UIImage(named: "ic_usFlagMediumIcn")
        return cell
    }
}
