import Foundation
import UIKit
import Nuke

open class InvoiceView: UIView {
    
    @IBOutlet weak var icBodyDispute: UIImageView!
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
        Bundle.main.loadNibNamed(R.nib.invoiceView.name, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    internal func initDispute() {
         self.initStatus(color: Theme.shared.greyStatusColor, status: R.string.localizable.invoiceStatusItemsDispute())
        self.icBodyDispute.isHidden = false
        self.status.isHidden = false
    }
    
    internal func initView(model: InvoiceModel) {
        self.name.text = model.merchantName
        if let amount = model.amount, let symbol = model.symbol {
            self.price.text = Formatter.formattedWithSeparator(value: String(amount)) + " " + symbol
        }
        self.billingCategory.text = model.billingCategory?.uppercased()
        if let number = model.number {
            self.invoiceNumber.text = "#" + number
        }
        if (model.status ==  InvoiceStatuses.Unpaid && !model.dispute!) {
            self.status.isHidden = true
            self.icBodyDispute.isHidden = true
        } else if (model.dispute!){
            self.initStatus(color: Theme.shared.greyStatusColor, status: R.string.localizable.invoiceStatusItemsDispute()) 
            self.icBodyDispute.isHidden = false
            self.status.isHidden = false
        } else {
            self.icBodyDispute.isHidden = true
            self.status.isHidden = false
        }
        if let date = model.iataInvoiceDate, let settlement = model.settlementMonthPeriod {
            self.info.text = date + " | " + settlement
        } else {
            self.info.text = ""
        }
        
        if let logoUrl = model.logoUrl, let url = URL(string: logoUrl){
            var request = ImageRequest(url: url)
            request.memoryCacheOptions.isWriteAllowed = true
            request.priority = .high
            Nuke.loadImage(with: request, into: self.logo)
        }
    }
    
    internal func initStatus(color: UIColor, status: String) {
        self.status.textColor = color
        self.status.text = status.uppercased()
        self.status.color = color
        self.status.sizeToFit()
        self.status.insets = UIEdgeInsetsMake(5, 7, 4, 7)
        self.icBodyDispute.isHidden = true
    }
    
}
