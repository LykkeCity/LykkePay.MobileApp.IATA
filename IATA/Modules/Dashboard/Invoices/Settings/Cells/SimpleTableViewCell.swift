import UIKit

class SimpleTableViewCell: UITableViewCell, OnSwitchStateChanged {

    @IBOutlet weak var nameLable: UILabel?
    @IBOutlet weak var switchState: BigThumbnailSwither!
    
    weak var delegate: OnSwitchStateChangedDelegate?
    
    var item: InvoiceSettingModel? {
        didSet {
            guard let item = item else {
                return
            }
            
            self.nameLable?.text = item.name
            self.switchState.setChecked(isChecked: self.item?.checked == nil ? false : self.item?.checked)
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
        self.switchState.delegate = self
    }
   
    func stateChanged(isSelected: Bool) {
        self.item?.checked = isSelected
        self.delegate?.stateChanged(isSelected: isSelected, item: self.item)
    }
}
