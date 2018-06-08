
import UIKit

class WalletsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var totalBalanceLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    private var testData = ["ivanov", "petrov", "sidorov", "ivanov", "petrov", "sidorov", "ivanov", "petrov", "sidorov", "ivanov", "petrov", "sidorov", "ivanov", "petrov", "sidorov", "ivanov", "petrov", "sidorov", "ivanov", "petrov", "sidorov", "ivanov", "petrov", "sidorov", "ivanov", "petrov", "sidorov"]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        let nib = UINib(nibName: "WalletsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "walletsCell")
        tableView.tableFooterView = UIView(frame: .zero)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "walletsCell") as?  WalletsTableViewCell else {
            return WalletsTableViewCell()
        }
        totalBalanceLabel.text = "123,234.61 $"
        cell.balanceLabel.text = "1231231 $"
        cell.walletsNameLabel.text = testData[indexPath.row]
        cell.nationalFlagImage.image = UIImage(named: "usFlagMediumIcn")
        return cell


    }


}
