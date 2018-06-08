import UIKit

class SimpleTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLable: UILabel?
    @IBOutlet weak var turnOn: UISwitch?
    
    var item: InvoiceModel? {
        didSet {
            guard let item = item else {
                return
            }
            
            nameLable?.text = item.name
        }
    }
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
