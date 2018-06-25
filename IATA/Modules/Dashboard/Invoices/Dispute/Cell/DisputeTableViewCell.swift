import UIKit

class DisputeTableViewCell: UITableViewCell {

    @IBOutlet weak var headerView: InvoiceView!
    @IBOutlet weak var reasonTextField: UILabel!
    
    @IBOutlet weak var invoiceView: InvoiceView!
    
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
        if let invoiceModel = model.invoice {
            self.invoiceView.initView(model: invoiceModel)
        }
        self.reasonTextField.text = model.reason
        self.reasonTextField.setLineSpacing(lineSpacing: 2.5)
        self.headerView.initDispute()
    }
    
    internal func initCell() {
        self.headerView.initDispute()
    }
    
}

