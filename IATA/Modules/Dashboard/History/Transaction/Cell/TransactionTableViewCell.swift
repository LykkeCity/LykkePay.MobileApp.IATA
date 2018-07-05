import UIKit

class TransactionTableViewCell: UITableViewCell {


    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var valueLable: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.valueLable.textContainerInset = UIEdgeInsetsMake(0, -self.valueLable.textContainer.lineFragmentPadding, 0, -self.valueLable.textContainer.lineFragmentPadding)
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    func initCell(model: PropertyKeyTransactionModel) {
        if let value = model.value {
            if value.isUrlString() {
                self.valueLable.attributedText = Theme.shared.getUrlAttributedString(message: value)
            } else {
                self.valueLable.attributedText = Theme.shared.getTransactionDetailsAttributedString(message: value)
            }
        }
        
        if let title = model.title {
            self.title.text = title
        }
    }
}
