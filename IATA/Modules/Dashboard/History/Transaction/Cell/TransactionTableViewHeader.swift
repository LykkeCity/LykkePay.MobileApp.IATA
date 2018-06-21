import UIKit

class TransactionTableViewHeader: UIView {

    @IBOutlet private weak var transactionTitle: UILabel!
    @IBOutlet private weak var transactionSubtitle: UILabel!
    @IBOutlet private weak var logo: UIImageView!
    @IBOutlet private weak var contentView: UIView!

    internal var model: HistoryTransactionModel? {
        willSet {
            guard let newValue = newValue else {
                return
            }
            updateUI(with: newValue)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed(R.nib.transactionTableViewHeader.name, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
    }

    private func updateUI(with model: HistoryTransactionModel) {
        transactionTitle.text = model.billingCategory
        transactionSubtitle.text = model.title
    }
}
