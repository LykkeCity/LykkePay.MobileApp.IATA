import UIKit

class InvoiceSettingsTableViewCell: UITableViewCell, OnSwitchStateChanged {
    
    @IBOutlet weak var widthImg: NSLayoutConstraint!
    @IBOutlet weak var heightImg: NSLayoutConstraint!
    @IBOutlet weak var swithFilter: BigThumbnailSwither!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var imgLogo: UIImageView!
   
    weak var delegate: OnSwitchStateChangedDelegate?
    
    var item: InvoiceSettingAirlinesModel? {
        didSet {
            guard let item = self.item else {
                return
            }
            self.name?.text = item.name
            self.swithFilter.setChecked(isChecked: self.item?.checked == nil ? false : self.item?.checked)
            
            let type = item.type
            if let isHiddern = type?.elementsEqual(InvoiceViewModelItemType.airlines.rawValue) {
                self.initLogo(isHidden: !isHiddern)
            }
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
        self.swithFilter.delegate = self
    }
    
    func stateChanged(isSelected: Bool) {
        self.item?.checked = isSelected
        self.delegate?.stateChanged(isSelected: isSelected, item: self.item)
    }
    
    func initLogo(isHidden: Bool) {
        self.imgLogo.isHidden = isHidden
        let size = CGFloat(isHidden ? 0 : 32)
        self.widthImg.constant = size
        self.heightImg.constant = size
    }
}
