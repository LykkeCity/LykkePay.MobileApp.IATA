import UIKit

class DisputeTableViewCell: UITableViewCell {

    @IBOutlet weak var headerView: InvoiceView!
    @IBOutlet weak var reasonTextField: UILabel!
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    internal func initCell(model: DisputeModel) {
        self.reasonTextField.text = model.reason
        self.reasonTextField.setLineSpacing(lineSpacing: 2.5)
        self.headerView.initDispute()
    }
    
    internal func initCell() {
        self.headerView.initDispute()
    }
    
}

