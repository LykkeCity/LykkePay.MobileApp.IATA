
import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var airlineImage: UIImageView!

    @IBOutlet weak var companyNameLabel: UILabel!

    @IBOutlet weak var usernameLabel: UILabel!

    @IBOutlet weak var emailLabel: UILabel!

    @IBOutlet weak var usdButton: UIButton!

    @IBOutlet weak var eurButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        fillTestData()
    }

    private func fillTestData() {
        companyNameLabel.text = "Air france"
        usernameLabel.text = "Annette Horn"
        emailLabel.text = "a.horn@iata.com"
    }

}
