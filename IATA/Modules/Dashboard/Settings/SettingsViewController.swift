import Nuke
import UIKit

class SettingsViewController: BaseNavController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var airlineImage: UIImageView!
    
    @IBOutlet weak var companyNameLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    var refresh = UIRefreshControl()
    
    private var state: DefaultSettingsState? = DefaultSettingsState()

    override func viewDidLoad() {
       /* removed by asking IATA baseCurrencyCollectionView.register(BaseCurrencyCollectionViewCell.nib, forCellWithReuseIdentifier: BaseCurrencyCollectionViewCell.identifier)
        baseCurrencyCollectionView.delegate = self
        baseCurrencyCollectionView.dataSource  = self
        baseCurrencyCollectionView.allowsMultipleSelection = false*/
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        
        self.initScrollView()
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
       /* removed by asking iata
        guard let cell = baseCurrencyCollectionView.dequeueReusableCell(withReuseIdentifier: BaseCurrencyCollectionViewCell.identifier, for: indexPath) as? BaseCurrencyCollectionViewCell else {
            return BaseCurrencyCollectionViewCell()
        }
        if let currency = self.state?.items[indexPath.row] {
            cell.initView(model: currency)
            if currency.isSelected! {
             baseCurrencyCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
            }
        }*/
        return UICollectionViewCell()
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
        PushNotificationHelper.unregisterInAzureHUB()
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(SignInViewController(), animated: true)
    }
    
    @objc private func logoutButtonTapped() {
        let logoutSheet = UIAlertController(title: nil, message: nil, preferredStyle:  .actionSheet)
        let logoutAction = UIAlertAction(title: R.string.localizable.settingLogoutItemLogout(), style: .default, handler: logout)
        logoutAction.setValue(Theme.shared.logoutTitle, forKey: "titleTextColor")
        logoutSheet.addAction(logoutAction)
        logoutSheet.addAction(UIAlertAction(title: R.string.localizable.settingLogoutItemCancel(), style: .cancel, handler: nil))
        logoutSheet.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        logoutSheet.popoverPresentationController?.sourceView = self.view
        self.present(logoutSheet, animated: true, completion: nil)
    }

    private func loadData() {
        self.beginRefresh()
        self.state?.getSettingsStringJson()
            .then(execute: { [weak self] (result: SettingsModel) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.fillUsersInfo(settingsModel: result)
            })
            .catch(execute: { [weak self] error -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.generateErrorAlert(error: error)
                strongSelf.refresh.endRefreshing()
            })
    }

    private func setSelectedBaseAsset(baseAsset: String, selectedCurrency: SettingsMerchantsModel ) {
        self.beginRefresh()
        self.state?.setBaseAsset(baseAsset: baseAsset)
            .then(execute: { [weak self] (result:Void) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.refresh.endRefreshing()
                UserPreference.shared.saveCurrentCurrency(selectedCurrency)
            })
    }

    private func fillUsersInfo(settingsModel: SettingsModel) {
        let settingsViewModel = state?.mappingSettings(settingsModel: settingsModel)
        Nuke.loadImage(with: URL(string: (settingsViewModel?.merchantLogoUrl)!)!, into: self.airlineImage)
        self.companyNameLabel.text = settingsViewModel?.merchantName
        if let firstName = settingsViewModel?.firstName, let lastName = settingsViewModel?.lastName {
            self.usernameLabel.text = firstName + " " + lastName
        }
        self.emailLabel.text = settingsViewModel?.email
        self.state?.getBaseAssetsStringJson()
            .then(execute: { [weak self] (result: String) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.fillAssetsInfo(from: result)
            })
    }

    private func fillAssetsInfo(from jsonString: String!) {
        self.state?.mappingBaseAssets(jsonString: jsonString)
       // self.baseCurrencyCollectionView.reloadData()
        self.refresh.endRefreshing()
    }

  
    override func getTitle() -> String? {
        return tabBarItem.title?.capitalizingFirstLetter()
    }

    override func getTableView() -> UITableView {
        return UITableView()
    }

    override func registerCells() {

    }
    @objc func didPullToRefresh() {
        self.loadData()
    }
    
    private func initScrollView() {
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.alwaysBounceVertical = true
        self.scrollView.bounces  = true
        self.refresh.attributedTitle = NSAttributedString(string:  R.string.localizable.commonLoadingMessage())
        self.refresh.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.scrollView.addSubview(refresh)
    }
    
    private func beginRefresh() {
        var offset = self.scrollView.contentOffset
        offset.y = -81
        self.refresh.endRefreshing()
        self.refresh.beginRefreshing()
        self.scrollView.contentOffset = offset
    }
}
