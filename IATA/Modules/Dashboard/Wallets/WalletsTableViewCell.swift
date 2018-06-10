
import UIKit

class WalletsTableViewCell: UITableViewCell {

    @IBOutlet weak var balanceLabel: UILabel!

    @IBOutlet weak var walletsNameLabel: UILabel!

    @IBOutlet weak var nationalFlagImage: UIImageView!

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
