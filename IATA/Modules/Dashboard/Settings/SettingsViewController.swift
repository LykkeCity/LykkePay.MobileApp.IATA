
import UIKit

class SettingsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var airlineImage: UIImageView!
    
    @IBOutlet weak var companyNameLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var baseCurrencyCollectionView: UICollectionView!
    
    private var state: SettingsState = DefaultSettingsState() as SettingsState
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fillTestData()
        self.baseCurrencyCollectionView.delegate = self
        self.baseCurrencyCollectionView.dataSource   = self
        self.baseCurrencyCollectionView.register(BaseCurrencyCollectionViewCell.nib, forCellWithReuseIdentifier: BaseCurrencyCollectionViewCell.identifier)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = Theme.shared.tabBarBackgroundColor
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = tabBarItem.title
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_bodyLogoutIcn"), style: .plain, target: self, action: #selector(logoutButtonTapped))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.state.getCurrencies().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = baseCurrencyCollectionView.dequeueReusableCell(withReuseIdentifier: BaseCurrencyCollectionViewCell.identifier, for: indexPath) as? BaseCurrencyCollectionViewCell else {
            return BaseCurrencyCollectionViewCell()
        }
        let currency = self.state.getCurrencies()[indexPath.row]
        
        cell.initView(model: currency)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! BaseCurrencyCollectionViewCell
        cell.isSelected = true
    }
    
    func logout(alert: UIAlertAction!) {
        CredentialManager.shared.clearSavedData()
        self.navigationController?.pushViewController(SignInViewController(), animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc private func logoutButtonTapped() {
        let logoutSheet = UIAlertController(title: nil, message: nil, preferredStyle:  .actionSheet)
        let logoutAction = UIAlertAction(title: "Setting.Logout.Item.Logout".localize(), style: .default, handler: logout)
        logoutAction.setValue(Theme.shared.logoutTitle, forKey: "titleTextColor")
        logoutSheet.addAction(logoutAction)
        logoutSheet.addAction(UIAlertAction(title: "Setting.Logout.Item.Cancel".localize(), style: .cancel, handler: nil))
        self.present(logoutSheet, animated: true, completion: nil)
    }
    
    private func fillTestData() {
        self.companyNameLabel.text = "Air france"
        self.usernameLabel.text = "Annette Horn"
        self.emailLabel.text = "a.horn@iata.com"
    }
    
}
