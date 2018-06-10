
class InvoiceBillingCategoriesItem: InvoiceViewModelItem {
    var type: InvoiceViewModelItemType {
        return .billingCategories
    }
    
    var sectionTitle: String {
        return "Invoice.Settings.BillingCategories.Title".localize()
    }
    
    var rowCount: Int {
        return billingCategories.count
    }
    
    var billingCategories: [InvoiceSettingModel]
    
    init(billingCategories: [InvoiceSettingModel]) {
        self.billingCategories = billingCategories
    }
}
