import Foundation
import UIKit

open class InvoiceView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var status: UiStatusView!
    @IBOutlet weak var billingCategory: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var invoiceNumber: UILabel!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var info: UILabel!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupDefaults()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDefaults()
    }
    
    private func setupDefaults() {
        Bundle.main.loadNibNamed("InvoiceView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    internal func initView(model: InvoiceModel) {
        self.name.text = model.clientName
        self.price.text = String(model.amount!) + getCurrency(currency: model.settlementAssetId)
        self.billingCategory.text = model.billingCategory
        self.invoiceNumber.text = model.number
        if (model.status ==  InvoiceStatuses.Unpaid && !model.dispute!) {
            if (!model.dispute!) {
                self.status.isHidden = true
            }
        }
        //TODO add after api will be ready info =
    }
    
    internal func initStatus(color: UIColor, status: String) {
        self.status.textColor = color
        self.status.text = status.uppercased()
        self.status.color = color
        self.status.sizeToFit()
        self.status.insets = UIEdgeInsetsMake(2, 3, 2, 3)
    }
    
    //TODO hope it's for some time, before improving api
    private func getCurrency(currency: String!) -> String {
        if (currency.contains("USD")) {
            return "$"
        } else {
            return "€"
        }
    }
}
