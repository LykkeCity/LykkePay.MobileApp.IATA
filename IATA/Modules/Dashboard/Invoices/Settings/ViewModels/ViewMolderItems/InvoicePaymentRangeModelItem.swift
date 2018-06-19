
class InvoicePaymentRangeItem: InvoiceViewModelItem {
    
    var type = InvoiceViewModelItemType.paymentRange
    var paymentRange: InvoiceSettingPaymentRangeItemModel
    
    func setType(type: InvoiceViewModelItemType) {
        self.type =  .paymentRange
    }
    
    func getType() -> InvoiceViewModelItemType? {
        return type
    }
    
    func getSectionTitle() -> String? {
        return R.string.localizable.invoiceSettingsPaymentRangeTitle()
    }
    
    func rowCount() -> Int {
        return 1
    }
    
    init(paymentRange: InvoiceSettingPaymentRangeItemModel) {
        self.paymentRange = paymentRange
    }
}
