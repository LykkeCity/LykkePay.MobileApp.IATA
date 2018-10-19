

import UIKit

class CustomHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var balanceLabel: UILabel!
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    static var identifier: String {
        return String(describing: self)
    }
  
}
