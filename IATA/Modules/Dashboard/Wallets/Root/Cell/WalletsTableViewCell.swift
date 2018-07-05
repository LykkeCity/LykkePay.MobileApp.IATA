
import UIKit

protocol WalletsCellClick: AnyObject {
    func bttnTapped(cell: WalletsTableViewCell)
}

class WalletsTableViewCell: UITableViewCell {

    @IBOutlet weak var balanceLabel: UILabel!

    @IBOutlet weak var walletsNameLabel: UILabel!

    @IBOutlet weak var nationalFlagImage: UIImageView!

    @IBOutlet weak var cashoutButton: UIButton!

    @IBOutlet weak var subView: UIView!

    weak var delegate: WalletsCellClick?

    private var walletsNationalFlag = ""

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        initViewTheme()
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
            return Formatter.formattedWithSeparator(valueDouble: baseAssetBalance)  + " $"
        } else if assetId.isEuro() {
            walletsNationalFlag = R.image.ic_eurFlagMediumIcn.name
            return Formatter.formattedWithSeparator(valueDouble: baseAssetBalance) + " €"
        }
        return Formatter.formattedWithSeparator(valueDouble: baseAssetBalance)
    }

    @IBAction func cashoutClicked(_ sender: Any) {
        delegate?.bttnTapped(cell: self)
    }
    private func initViewTheme() {
        self.cashoutButton.layer.cornerRadius = 2
        self.subView.layer.borderWidth = 0.5
        self.subView.layer.cornerRadius = 4
        self.subView.layer.borderColor = Theme.shared.unselectedBaseCurrencyBorderCell.cgColor
    }
}
