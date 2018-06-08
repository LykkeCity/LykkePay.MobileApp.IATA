
class InvoicePaymentRangeItem: InvoiceViewModelItem {
    var type: InvoiceViewModelItemType {
        return .paymentRange
    }
    
    var sectionTitle: String {
        return "Invoice.Settings.PaymentRange.Title".localize()
    }
    
    var rowCount: Int {
        return 1
    }
    
    var paymentRange: InvoicePaymentRangeItemModel
    
    init(paymentRange: InvoicePaymentRangeItemModel) {
        self.paymentRange = paymentRange
    }
}
