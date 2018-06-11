
import UIKit

class InvoiceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var viewBox: UIView!
    @IBOutlet weak var additionalStatus: UiStatusView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelInfo: UILabel!
    @IBOutlet weak var labelMiscellaneous: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var labelSubtitle: UILabel!
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
        //fot test
        initStatus(color: Theme.shared.greenColor, status: "paid")
        initCheckBox(color: Theme.shared.greenColor)
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
        initStatus(color: Theme.shared.greenColor, status: "paid")
        initCheckBox(color: Theme.shared.greenColor)
    }
    
    
    private func initCheckBox(color: UIColor) {
        self.checkBox.borderStyle = .circle
        self.checkBox.checkmarkStyle = .circle
        self.checkBox.borderWidth = 1
        self.checkBox.uncheckedBorderColor = .lightGray
        self.checkBox.checkedBorderColor = color
        self.checkBox.checkmarkSize = 0.6
        self.checkBox.checkmarkColor = color
        self.checkBox.addTarget(self, action: #selector(checkboxValueChanged(sender:)), for: .valueChanged)
        self.viewBox.addSubview(checkBox)
    }
    
}
