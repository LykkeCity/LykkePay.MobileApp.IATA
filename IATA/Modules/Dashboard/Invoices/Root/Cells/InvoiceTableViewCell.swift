
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
    
    internal func initModel(model: InvoiceModel) {
        initFullCheckBoxStatus(model)
      
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
    
    private func initCheckBoxAndStatus(color: UIColor, isCanBePaid: Bool, titleStatus: String) {
        self.initCheckBox(color: color, isCanBePaid: isCanBePaid)
        self.initStatus(color: color,  status: titleStatus)
    }
    
    private func initCheckBox(color: UIColor, isCanBePaid: Bool) {
        self.checkBox.borderStyle = .circle
        self.checkBox.checkmarkStyle = .circle
        self.checkBox.borderWidth = 1
        self.checkBox.uncheckedBorderColor = .lightGray
        self.checkBox.checkedBorderColor = color
        self.checkBox.checkmarkSize = 0.6
        self.checkBox.checkmarkColor = color
        self.checkBox.isChecked = true
        if (isCanBePaid) {
            self.checkBox.addTarget(self, action: #selector(checkboxValueChanged(sender:)), for: .valueChanged)
        }
        self.checkBox.isCanBeChanged = true
        self.viewBox.addSubview(checkBox)
        self.checkBox.alpha = isCanBePaid ? 1.0 : 0.4
    }
    
    private func initFullCheckBoxStatus(_ model: InvoiceModel) {
        switch model.status {
        case .Unpaid?:
            if (model.dispute)! {
                initCheckBoxAndStatus(color: Theme.shared.greyStatusColor, isCanBePaid: true, titleStatus: "Invoice.Status.Items.Dispute".localize())
            } else {
                self.additionalStatus.isHidden = true
            }
            break
        case .InProgress?:
            initCheckBoxAndStatus(color: Theme.shared.blueProgressStatusColor, isCanBePaid: false, titleStatus: "Invoice.Status.Items.InProgress".localize())
            break
        case .Paid?:
            initCheckBoxAndStatus(color: Theme.shared.greenColor, isCanBePaid: false, titleStatus: "Invoice.Status.Items.Paid".localize())
            break
        case .Underpaid?:
            initCheckBoxAndStatus(color: Theme.shared.greenColor, isCanBePaid: true, titleStatus: "Invoice.Status.Items.Underpaid".localize())
            break
        case .Overpaid?:
            initCheckBoxAndStatus(color: Theme.shared.redErrorStatusColor, isCanBePaid: false, titleStatus: "Invoice.Status.Items.Overpaid".localize())
            break
        case .LatePaid?:
            initCheckBoxAndStatus(color: Theme.shared.redErrorStatusColor, isCanBePaid: false, titleStatus:"Invoice.Status.Items.Latepaid".localize())
            break
        case .InternalError?:
            initCheckBoxAndStatus(color: Theme.shared.redErrorStatusColor, isCanBePaid: false, titleStatus:"Invoice.Status.Items.InternalError".localize())
            break
        case .PastDue?:
            initCheckBoxAndStatus(color: Theme.shared.redErrorStatusColor, isCanBePaid: false, titleStatus: "Invoice.Status.Items.PastDue".localize())
            break
        default:
            self.additionalStatus.isHidden = true
            self.checkBox.isHidden = true
            break
        }
        
    }
    
    
}
