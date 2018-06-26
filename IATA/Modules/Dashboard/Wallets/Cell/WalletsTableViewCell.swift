
import UIKit

class WalletsTableViewCell: UITableViewCell {

    @IBOutlet weak var balanceLabel: UILabel!

    @IBOutlet weak var walletsNameLabel: UILabel!

    @IBOutlet weak var nationalFlagImage: UIImageView!

    private var walletsNationalFlag = ""

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    static var identifier: String {
        return String(describing: self)
    }

    internal func fillCell(from model: WalletsViewModel) {
        if let assetId = model.assetId, let baseAssetBalance = model.totalBalance {
            walletsNameLabel.text = assetId
            balanceLabel.text = prepareBaseAssetBalanceValue(from: baseAssetBalance, and: assetId)
            nationalFlagImage.image = UIImage(named: walletsNationalFlag)
        }
    }

    //for test - as api isn't ready
    private func prepareBaseAssetBalanceValue(from baseAssetBalance : Double, and assetId: String) -> String {
        if assetId.isUsd() {
            walletsNationalFlag = R.image.ic_usFlagMediumIcn.name
            return String(baseAssetBalance) + " $"
        } else if assetId.isEuro() {
             walletsNationalFlag = R.image.ic_eurFlagMediumIcn.name
            return String(baseAssetBalance) + " €"
        }
        return String(baseAssetBalance)
    }
}
