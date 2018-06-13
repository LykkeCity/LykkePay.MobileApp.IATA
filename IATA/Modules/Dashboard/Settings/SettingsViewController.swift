
import UIKit

class SettingsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var airlineImage: UIImageView!

    @IBOutlet weak var companyNameLabel: UILabel!

    @IBOutlet weak var usernameLabel: UILabel!

    @IBOutlet weak var emailLabel: UILabel!

    @IBOutlet weak var baseCurrencyCollectionView: UICollectionView!

    private let currencies = ["USD", "EUR"]

    private let currencyImages = ["ic_usFlagSmallIcn","ic_eurFlagSmallIcn"]

    override func viewDidLoad() {
        super.viewDidLoad()
        fillTestData()
        baseCurrencyCollectionView.delegate = self
        baseCurrencyCollectionView.dataSource   = self
        baseCurrencyCollectionView.register(BaseCurrencyCollectionViewCell.nib, forCellWithReuseIdentifier: BaseCurrencyCollectionViewCell.identifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = Theme.shared.tabBarBackgroundColor
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = tabBarItem.title
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_bodyLogoutIcn"), style: .plain, target: self, action: #selector(logoutButtonTapped))

        let defaultIndexPathForTesting = IndexPath(row: 0, section: 0)
        baseCurrencyCollectionView.selectItem(at: defaultIndexPathForTesting, animated: false, scrollPosition: .top)
    }

    private func fillTestData() {
        companyNameLabel.text = "Air france"
        usernameLabel.text = "Annette Horn"
        emailLabel.text = "a.horn@iata.com"
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = baseCurrencyCollectionView.dequeueReusableCell(withReuseIdentifier: BaseCurrencyCollectionViewCell.identifier, for: indexPath) as? BaseCurrencyCollectionViewCell else {
            return BaseCurrencyCollectionViewCell()
        }
        cell.baseCurrencyFlagImage.image = UIImage(named: currencyImages[indexPath.row])
        cell.baseCurrencyNameLabel.text = currencies[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! BaseCurrencyCollectionViewCell
        cell.isSelected = true
    }

    @objc private func logoutButtonTapped() {
        let logoutSheet = UIAlertController(title: nil, message: nil, preferredStyle:  .actionSheet)
        let logoutAction = UIAlertAction(title: "Setting.Logout.Item.Logout".localize(), style: .default, handler: nil)
        logoutAction.setValue(Theme.shared.logoutTitle, forKey: "titleTextColor")
        logoutSheet.addAction(logoutAction)
        logoutSheet.addAction(UIAlertAction(title: "Setting.Logout.Item.Cancel".localize(), style: .cancel, handler: nil))
        self.present(logoutSheet, animated: true, completion: nil)
    }

};
    extension SettingsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: baseCurrencyCollectionView.bounds.width/2 - 5 , height: 56)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(10)
    }
}
