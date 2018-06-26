import UIKit

class TransactionTableViewCell: UITableViewCell {

    @IBOutlet weak var valueLable: UILabel!
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    func initCell(model: PropertyKeyTransactionModel) {
        if let value = model.value {
            self.valueLable.text = value
        }
        
        if let title = model.title {
            self.title.text = title
        }
    }
}
