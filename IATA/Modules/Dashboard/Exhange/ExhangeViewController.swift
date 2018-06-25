import UIKit

class ExhangeViewController: BaseNavController {

    @IBOutlet weak var topView: UIView!

    private let state = DefaultExchangeState()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        initTheme()
        loadWallets()
    }

    private func initTheme() {
        self.topView.layer.borderWidth = 0.5
        self.topView.layer.cornerRadius = 4
        self.topView.layer.borderColor = Theme.shared.exchangeTopViewBorderColor.cgColor
    }
    
    override func getTitle() -> String? {
        return tabBarItem.title?.capitalizingFirstLetter()
    }

    @IBAction func makeExchange(_ sender: Any) {

    }

    private func loadWallets() {
        self.state?.walletsState?.getWalletsStringJson()
            .withSpinner(in: view)
            .then(execute: { [weak self] (result: String) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.parse(jsonString: result)
            })
    }

    private func parse(jsonString: String!) {
        self.state?.walletsState?.mapping(jsonString: jsonString)
        var wallets = self.state?.walletsState?.getItems()
    }
}


