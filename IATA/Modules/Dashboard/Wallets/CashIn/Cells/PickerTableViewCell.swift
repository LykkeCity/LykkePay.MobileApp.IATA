import UIKit

class PickerTableViewCell: UITableViewCell {

    @IBOutlet weak var tickImage: UIImageView!
    @IBOutlet weak var nameAssetId: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    func fillCell(name: String?, isSelected: Bool?) {
        self.nameAssetId.text = name
        if let selected = isSelected {
            self.tickImage.isHidden = !selected
        }
    }
    
}
