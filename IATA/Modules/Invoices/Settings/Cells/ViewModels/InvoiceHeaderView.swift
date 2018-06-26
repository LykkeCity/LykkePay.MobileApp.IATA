import UIKit

class InvoiceHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var downDividerView: UIView!
    @IBOutlet weak var title: UILabel!
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}
