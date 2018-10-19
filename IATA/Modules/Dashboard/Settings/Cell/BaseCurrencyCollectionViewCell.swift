
import UIKit

class BaseCurrencyCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var baseCurrencyFlagImage: UIImageView!

    @IBOutlet weak var baseCurrencyNameLabel: UILabel!
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                applySelectedCellTheme()
            } else {
                applyUnselectedCellTheme()
            }

        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        applyUnselectedCellTheme()
    }

    internal func initView(model: SettingsMerchantsModel) {

        self.baseCurrencyNameLabel.text = model.value
        if let isSelected = model.isSelected {
            self.isSelected = isSelected
            self.layoutIfNeeded()
            if isSelected {
              UserPreference.shared.saveCurrentCurrency(model)
            }
        }
        if let symbol = model.id {
        if (symbol.isUsd()) {
            self.baseCurrencyFlagImage.image = R.image.ic_usFlagMediumIcn()
        } else if (symbol.isEuro())  {
            self.baseCurrencyFlagImage.image = R.image.ic_eurFlagMediumIcn()
            }
        }

    }

    private func applySelectedCellTheme() {
        generateCellTheme(borderWidth: 1, cornerRadius: 4, borderColor: Theme.shared.selectedBaseCurrencyBorderCell.cgColor)
    }

    private func applyUnselectedCellTheme() {
        generateCellTheme(borderWidth: 1, cornerRadius: 4, borderColor: Theme.shared.unselectedBaseCurrencyBorderCell.cgColor)
    }

    private func generateCellTheme(borderWidth: CGFloat, cornerRadius: CGFloat, borderColor: CGColor ){
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = cornerRadius
        self.layer.borderColor = borderColor
    }

    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    static var identifier: String {
        return String(describing: self)
    }
}

