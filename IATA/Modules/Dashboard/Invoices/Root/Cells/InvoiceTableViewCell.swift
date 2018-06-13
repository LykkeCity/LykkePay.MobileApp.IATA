
import UIKit

class InvoiceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var viewBox: UIView!
    @IBOutlet weak var additionalStatus: UiStatusView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelInfo: UILabel!
    @IBOutlet weak var labelMiscellaneous: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var labelSubtitle: UILabel!
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var logoInvoice: UIImageView!
    
    weak var delegate: OnChangeStateSelected?
    let checkBox = Checkbox(frame: CGRect(x: 5 , y: 5, width: 15, height: 15))
    
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
    
    internal func initStatus(color: UIColor, status: String) {
        additionalStatus.textColor = color
        additionalStatus.text = status.uppercased()
        additionalStatus.color = color
        additionalStatus.sizeToFit()
        additionalStatus.insets = UIEdgeInsetsMake(2, 3, 2, 3)
    }
    
    internal func initModel(model: InvoiceModel, isChecked: Bool) {
        initFullCheckBoxStatus(model, isChecked: isChecked)
      
        self.labelName.text = model.clientName
        self.labelPrice.text = String(model.amount!) + getCurrency(currency: model.settlementAssetId)
        self.labelMiscellaneous.text = model.billingCategory
        self.labelInfo.text = model.number
        
        //TODO add after api will be ready self.labelSubtitle.text =
    }
    
    //TODO hope it's for some time, before improving api
    private func getCurrency(currency: String!) -> String {
        if (currency.contains("USD")) {
            return "$"
        } else {
            return "€"
        }
    }
    
    private func initCheckBoxAndStatus(structInfo: InvoiceStatusesStruct, isChecked: Bool) {
        self.initCheckBox(color: structInfo.color!, isCanBePaid: structInfo.isCanBePaid!, isChecked: isChecked)
        self.initStatus(color: structInfo.color!,  status: structInfo.title!)
    }
    
    private func initCheckBox(color: UIColor, isCanBePaid: Bool, isChecked: Bool) {
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
        let structInfo = InvoiceStatusesStruct(type: model.status!)
        initCheckBoxAndStatus(structInfo: structInfo, isChecked: isChecked)
        if (model.status ==  InvoiceStatuses.Unpaid && !model.dispute!) {
            if (!model.dispute!) {
                self.additionalStatus.isHidden = true
            }
        }
        
    }
    
    
}
