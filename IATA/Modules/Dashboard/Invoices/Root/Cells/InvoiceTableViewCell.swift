
import UIKit

class InvoiceTableViewCell: SwipeTableViewCell {
    
    @IBOutlet weak var viewBox: UIView!
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var invoiceView: InvoiceView!
    @IBOutlet weak var widthBox: NSLayoutConstraint!
    @IBOutlet weak var leftLeading: NSLayoutConstraint!
    @IBOutlet weak var invoiceClickablePart: UIView!
    
    
    weak var delegateChanged: OnChangeStateSelected?
    let checkBox = Checkbox(frame: CGRect(x: 5 , y: 5, width: 15, height: 15))
    var isCanBePaid = true
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @objc func clickSelected(sender: Any?) {
        checkBox.isChecked = !checkBox.isChecked
    }
    
    @objc func checkboxValueChanged(sender: Checkbox) {
        if let isDisabled = delegateChanged?.isDisabled(), !isDisabled {
            delegateChanged?.onItemSelected(isSelected: self.checkBox.isChecked, index: self.checkBox.tag)
        } else {
            self.checkBox.isChecked = !self.checkBox.isChecked
        }
    }
    
    @objc func clicked() {
        if let isDisabled = delegateChanged?.isDisabled(), !isDisabled {
            self.checkBox.isChecked = !self.checkBox.isChecked
            delegateChanged?.onItemSelected(isSelected: self.checkBox.isChecked, index: self.checkBox.tag)
        } else {
            self.checkBox.isChecked = self.checkBox.isChecked
        }
    }
    
    internal func initModel(model: InvoiceModel, isChecked: Bool) {
        self.initFullCheckBoxStatus(model, isChecked: isChecked)
        
        self.invoiceView.initView(model: model, cell: self)
        self.viewBox.isHidden = UserPreference.shared.isSuperviser()
        self.widthBox.constant = UserPreference.shared.isSuperviser() ? 0 : 30
        self.leftLeading.constant = UserPreference.shared.isSuperviser() ? 8 : 12
    }
    
    private func initCheckBoxAndStatus(structInfo: InvoiceStatusesStruct, isChecked: Bool) {
        self.initCheckBox(color: structInfo.color, isCanBePaid: structInfo.isCanBePaid, isChecked: isChecked)
        self.invoiceView.initStatus(color: structInfo.colorStatus,  status: structInfo.title)
    }
    
    private func initCheckBox(color: UIColor, isCanBePaid: Bool, isChecked: Bool) {
        self.isCanBePaid = isCanBePaid
        self.checkBox.borderStyle = .circle
        self.checkBox.checkmarkStyle = .circle
        self.checkBox.borderWidth = 1
        self.checkBox.uncheckedBorderColor = .lightGray
        self.checkBox.checkedBorderColor = color
        self.checkBox.checkmarkSize = 0.6
        self.checkBox.checkmarkColor = color
        self.checkBox.frame = CGRect(x: 4, y: 20, width: 12, height: 12)
        self.checkBox.isChecked = isCanBePaid ? isChecked : true
        if (isCanBePaid) {
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.clicked))
            self.viewBox.addGestureRecognizer(tap)
            self.invoiceClickablePart.addGestureRecognizer(tap)
            self.checkBox.addTarget(self, action: #selector(checkboxValueChanged(sender:)), for: .valueChanged)
        }
        self.checkBox.isCanBeChanged = isCanBePaid
        self.viewBox.addSubview(checkBox)
        self.checkBox.alpha = isCanBePaid ? 1.0 : 0.4
    }
    
    private func initFullCheckBoxStatus(_ model: InvoiceModel, isChecked: Bool) {
        guard let status = model.status else {
            return
        }
        var structInfo = InvoiceStatusesStruct(type: status)
        if (model.dispute)! {
            structInfo.isCanBePaid = false
            structInfo.color = Theme.shared.redErrorStatusColor
        }
        initCheckBoxAndStatus(structInfo: structInfo, isChecked: isChecked)
    }
    
}
