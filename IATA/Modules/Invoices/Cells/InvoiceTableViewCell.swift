
import UIKit

class InvoiceTableViewCell: UITableViewCell {

    @IBOutlet weak var viewBox: UIView!
    @IBOutlet weak var additionalStatus: UiStatusView!
    
    let checkBox = Checkbox(frame: CGRect(x: 5 , y: 5, width: 15, height: 15))
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkBox.borderStyle = .circle
        checkBox.checkmarkStyle = .circle
        checkBox.borderWidth = 1
        checkBox.uncheckedBorderColor = .lightGray
        checkBox.checkedBorderColor = .blue
        checkBox.checkmarkSize = 0.4
        checkBox.checkmarkColor = .blue
        viewBox.addSubview(checkBox)
        additionalStatus.textColor = UIColor.black
        additionalStatus.text = "test"
        additionalStatus.sizeToFit()
        additionalStatus.insets = UIEdgeInsetsMake(0, 5, 0, 5)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
