
import UIKit

class InvoiceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var viewBox: UIView!
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var invoiceView: InvoiceView!
    
    weak var delegate: OnChangeStateSelected?
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
        delegate?.onItemSelected(isSelected: sender.isChecked, index: sender.tag)
    }
    
    
    internal func initModel(model: InvoiceModel, isChecked: Bool) {
        self.initFullCheckBoxStatus(model, isChecked: isChecked)
        self.invoiceView.initView(model: model)
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
        self.checkBox.isChecked = isCanBePaid ? isChecked : true
        if (isCanBePaid) {
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
