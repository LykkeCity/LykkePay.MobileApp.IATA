import UIKit

class AirlinesTableViewCell: UITableViewCell, OnSwitchStateChanged {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var picture: UIImage!
    @IBOutlet weak var switchOnOffFilter: BigThumbnailSwither!
     weak var delegate: OnSwitchStateChangedDelegate?
    
    var item: InvoiceSettingAirlinesModel? {
        didSet {
            guard let item = item else {
                return
            }
            
            if let pictureUrl = item.logo {
                
            }
            
            self.name?.text = item.name
            self.switchOnOffFilter.setChecked(isChecked: self.item?.checked == nil ? false : self.item?.checked)
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
    }
    
    func stateChanged(isSelected: Bool) {
        self.item?.checked = isSelected
        self.delegate?.stateChanged(isSelected: isSelected, item: self.item)
    }
}
