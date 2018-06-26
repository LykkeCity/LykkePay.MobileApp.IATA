import UIKit

class ViewController: UIViewController {

    @IBAction func clickLogout(_ sender: Any) {
        CredentialManager.shared.clearSavedData()
        self.navigationController?.pushViewController(SignInViewController(), animated: false)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
