
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
    //TODO change this method when api will be return data
    internal func fillCell(from model: WalletsModel) {
        if let assetId = model.assetId, let baseAssetBalance = model.baseAssetBalance {
            walletsNameLabel.text = assetId
            balanceLabel.text = prepareBaseAssetBalanceValue(from: baseAssetBalance, and: assetId)
            nationalFlagImage.image = UIImage(named: walletsNationalFlag)
        }
    }

    private func prepareBaseAssetBalanceValue(from baseAssetBalance : Double, and assetId: String) -> String {
        if assetId.contains("USD") {
            walletsNationalFlag = "ic_usFlagMediumIcn"
            return String(baseAssetBalance) + " $"
        }
        else if assetId.contains("EUR") {
             walletsNationalFlag = "ic_eurFlagMediumIcn"
            return String(baseAssetBalance) + " €"
        }
        return ""
    }
}
