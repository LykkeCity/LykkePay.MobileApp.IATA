import UIKit

class AirlinesTableViewCell: UITableViewCell, OnSwitchStateChanged {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var picture: UIImage!
    @IBOutlet weak var switchOnOffFilter: BigThumbnailSwither!
    
    
    var item: InvoiceSettingAirlinesModel? {
        didSet {
            guard let item = item else {
                return
            }
            
            if let pictureUrl = item.logo {
                
            }
            
            self.name?.text = item.name
            self.switchOnOffFilter.setChecked(isChecked: FilterPreference.shared.getChecked(key: item.name, type: item.type))
        }
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.switchOnOffFilter.delegate = self
        self.switchOnOffFilter.setChecked(isChecked: FilterPreference.shared.getChecked(key: item?.name, type: item?.type))
    }
    
    func stateChanged(isSelected: Bool) {
        FilterPreference.shared.saveFilteredKey(isSelected, key: item?.name, type: item?.type)
    }
}
