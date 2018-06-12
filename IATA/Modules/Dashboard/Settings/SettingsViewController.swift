
import UIKit

class SettingsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var airlineImage: UIImageView!

    @IBOutlet weak var companyNameLabel: UILabel!

    @IBOutlet weak var usernameLabel: UILabel!

    @IBOutlet weak var emailLabel: UILabel!

    @IBOutlet weak var baseCurrencyCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        fillTestData()
        baseCurrencyCollectionView.delegate = self
        baseCurrencyCollectionView.dataSource   = self
        let nib = UINib(nibName: "BaseCurrencyCollectionViewCell", bundle: nil)
        baseCurrencyCollectionView.register(nib, forCellWithReuseIdentifier: "baseCurrencyCell")
        
    }

    private func fillTestData() {
        companyNameLabel.text = "Air france"
        usernameLabel.text = "Annette Horn"
        emailLabel.text = "a.horn@iata.com"
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = baseCurrencyCollectionView.dequeueReusableCell(withReuseIdentifier: "baseCurrencyCell", for: indexPath) as? BaseCurrencyCollectionViewCell else {
            return BaseCurrencyCollectionViewCell()
        }
        cell.baseCurrencyFlagImage.image = UIImage(named: "ic_usFlagMediumIcn")
        cell.baseCurrencyNameLabel.text = "USD"
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! BaseCurrencyCollectionViewCell
        cell.isSelected = true
    }

}; extension SettingsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: baseCurrencyCollectionView.bounds.width/2 - 5 , height: 56)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(10)
    }
}
