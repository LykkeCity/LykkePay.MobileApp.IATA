import UIKit

class AirlinesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var picture: UIImage!
    @IBOutlet weak var turnOn: UISwitch!
    
    var item: AirlinesInvoiceModel? {
        didSet {
            guard let item = item else {
                return
            }
            
            if let pictureUrl = item.logo {
                
            }
            
            name?.text = item.name
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
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
