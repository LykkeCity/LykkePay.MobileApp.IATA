
import UIKit

class SettingsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

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
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: R.font.gothamProMedium(size: 17)]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = tabBarItem.title?.capitalizingFirstLetter()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.ic_bodyLogoutIcn(), style: .plain, target: self, action: #selector(logoutButtonTapped))

        self.view.layoutIfNeeded()
        let defaultIndexPathForTesting = IndexPath(row: 0, section: 0)
        baseCurrencyCollectionView.selectItem(at: defaultIndexPathForTesting, animated: false, scrollPosition: .top)
    }

    private func fillTestData() {
        companyNameLabel.text = "Air france"
        usernameLabel.text = "Annette Horn"
        emailLabel.text = "a.horn@iata.com"
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
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(SignInViewController(), animated: true)
    }
    
    @objc private func logoutButtonTapped() {
        let logoutSheet = UIAlertController(title: nil, message: nil, preferredStyle:  .actionSheet)
        let logoutAction = UIAlertAction(title: R.string.localizable.settingLogoutItemLogout(), style: .default, handler: logout)
        logoutAction.setValue(Theme.shared.logoutTitle, forKey: "titleTextColor")
        logoutSheet.addAction(logoutAction)
        logoutSheet.addAction(UIAlertAction(title: R.string.localizable.settingLogoutItemCancel(), style: .cancel, handler: nil))
        self.present(logoutSheet, animated: true, completion: nil)
    }

    private func logout(action: UIAlertAction) {
        CredentialManager.shared.clearSavedData()
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(SignInViewController(), animated: false)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: baseCurrencyCollectionView.bounds.width/2 - 5 , height: 56)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(10)
    }
}
