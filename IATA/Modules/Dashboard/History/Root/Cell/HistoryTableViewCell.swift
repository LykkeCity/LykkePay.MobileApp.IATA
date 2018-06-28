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

        setAmount(amount: model.amount, symbol: model.symbol)
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

    private func setAmount(amount: Int?, symbol: String?) {
        guard let amount = amount, let symbol = symbol else {
            return
        }
        if amount > 0  {
            self.transactionSum.text = "+" + String(amount) + symbol
            self.transactionSum.textColor = Theme.shared.greenColor
        } else {
            self.transactionSum.text = "-" + String(amount) + symbol
            self.transactionSum.textColor = Theme.shared.redErrorStatusColor
        }
    }
    
}
