import Nuke
import UIKit

class SettingsViewController: BaseNavController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var airlineImage: UIImageView!
    
    @IBOutlet weak var companyNameLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var baseCurrencyCollectionView: UICollectionView!

    private var state: DefaultSettingsState? = DefaultSettingsState()

    override func viewDidLoad() {
        baseCurrencyCollectionView.register(BaseCurrencyCollectionViewCell.nib, forCellWithReuseIdentifier: BaseCurrencyCollectionViewCell.identifier)
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        baseCurrencyCollectionView.delegate = self
        baseCurrencyCollectionView.dataSource  = self
        baseCurrencyCollectionView.allowsMultipleSelection = false
        loadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = self.state?.getItems().count {
            return count
        } else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = baseCurrencyCollectionView.dequeueReusableCell(withReuseIdentifier: BaseCurrencyCollectionViewCell.identifier, for: indexPath) as? BaseCurrencyCollectionViewCell else {
            return BaseCurrencyCollectionViewCell()
        }
        if let currency = self.state?.items[indexPath.row] {
            cell.initView(model: currency)
            if currency.isSelected! {
             baseCurrencyCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! BaseCurrencyCollectionViewCell
        cell.isSelected = true
        if let selectedCurrency = state?.getItems()[indexPath.row] {
            if let id = selectedCurrency.id {
                self.setSelectedBaseAsset(baseAsset: id, selectedCurrency: selectedCurrency)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! BaseCurrencyCollectionViewCell
        cell.isSelected = false
    }

    override func getRightButton() -> UIBarButtonItem? {
        return UIBarButtonItem(image: R.image.ic_bodyLogoutIcn(), style: .plain, target: self, action: #selector(self.logoutButtonTapped))
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

    private func loadData() {
        self.state?.getSettingsStringJson()
            .withSpinner(in: view)
            .then(execute: { [weak self] (result: String) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.fillUsersInfo(jsonString: result)
            })

        self.state?.getBaseAssetsStringJson()
            .withSpinner(in: view)
            .then(execute: { [weak self] (result: String) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.fillAssetsInfo(from: result)
            })
    }

    private func setSelectedBaseAsset(baseAsset: String, selectedCurrency: SettingsMerchantsModel ) {
        self.state?.setBaseAsset(baseAsset: baseAsset).withSpinner(in: view).then(execute: { [weak self] (result:Void) -> Void in
            guard let strongSelf = self else {
                return
            }
             UserPreference.shared.saveCurrentCurrency(selectedCurrency)
        })
    }

    private func fillUsersInfo(jsonString: String!) {
        let settingsViewModel = state?.mappingSettings(jsonString: jsonString)
        Nuke.loadImage(with: URL(string: (settingsViewModel?.merchantLogoUrl)!)!, into: self.airlineImage)
        self.companyNameLabel.text = settingsViewModel?.merchantName
        if let firstName = settingsViewModel?.firstName, let lastName = settingsViewModel?.lastName {
            self.usernameLabel.text = firstName + " " + lastName
        }
        self.emailLabel.text = settingsViewModel?.email
    }

    private func fillAssetsInfo(from jsonString: String!) {
        self.state?.mappingBaseAssets(jsonString: jsonString)
        self.baseCurrencyCollectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: baseCurrencyCollectionView.bounds.width/2 - 5 , height: 56)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(10)
    }

    override func getTitle() -> String? {
        return tabBarItem.title?.capitalizingFirstLetter()
    }

    override func getTableView() -> UITableView {
        return UITableView()
    }

    override func registerCells() {

    }
}
