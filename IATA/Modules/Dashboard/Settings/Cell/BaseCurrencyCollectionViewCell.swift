
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
    
    internal func initView(model: InvoiceSettingAirlinesModel) {
        self.baseCurrencyFlagImage.image = UIImage(named: model.logo!)
        self.baseCurrencyNameLabel.text = model.name
        self.isSelected = model.checked!
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

