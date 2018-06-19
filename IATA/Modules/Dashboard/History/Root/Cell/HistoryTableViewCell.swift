import UIKit
import Nuke

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
    
    internal func initCell(model: HistoryModel) {
        if let amount = model.amount, let symbol = model.symbol {
            self.transactionSum.text = amount + symbol
        }
        
        /*if Int(amount) > 0  {
            self.transactionSum.textColor = Theme.shared.greenColor
        } else {
            self.transactionSum.textColor = Theme.shared.redErrorStatusColor
        }*/
        if let name = model.title {
            self.titleLable.text = name
        }
        
        if let urlString = model.logo, let url = URL(string: urlString) {
            var request = ImageRequest(url: url)
            request.memoryCacheOptions.isWriteAllowed = true
            request.priority = .high
            Nuke.loadImage(with: request, into: self.logo)
        }
        
        if let date = model.timeStamp {
            self.infoLabel.text = date
        }
    }
    
}
