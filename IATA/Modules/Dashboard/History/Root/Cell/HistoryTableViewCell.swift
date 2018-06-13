import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var transactionSum: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var logo: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
}
