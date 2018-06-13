import UIKit

class SimpleTableViewCell: UITableViewCell, OnSwitchStateChanged {

    @IBOutlet weak var nameLable: UILabel?
    @IBOutlet weak var switchState: BigThumbnailSwither!
    
    
    var item: InvoiceSettingModel? {
        didSet {
            guard let item = item else {
                return
            }
            
            self.nameLable?.text = item.name
            self.switchState.setChecked(isChecked: FilterPreference.shared.getChecked(key: item.name, type: item.type))
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
        self.switchState.setChecked(isChecked: FilterPreference.shared.getChecked(key: item?.name, type: item?.type))
    }
   
    func stateChanged(isSelected: Bool) {
        FilterPreference.shared.saveFilteredKey(isSelected, key: item?.name, type: item?.type)
    }
    
    internal func reloadValue() {
          self.switchState.setChecked(isChecked: FilterPreference.shared.getChecked(key: item?.name, type: item?.type))
    }
}
