import Foundation

class InvoiceCurrenciesViewModeItem: InvoiceViewModelItem {
    var type: InvoiceViewModelItemType {
        return .currencies
    }
    
    var sectionTitle: String {
        return "Invoice.Settings.Currencies.Title".localize()
    }
    
    var rowCount: Int {
        return currencies.count
    }
    
    var currencies: [InvoiceModel]
    
    init(currencies: [InvoiceModel]) {
        self.currencies = currencies
    }
}
