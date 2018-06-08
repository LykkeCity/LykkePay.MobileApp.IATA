
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
    
    var billingCategories: [InvoiceModel]
    
    init(billingCategories: [InvoiceModel]) {
        self.billingCategories = billingCategories
    }
}
