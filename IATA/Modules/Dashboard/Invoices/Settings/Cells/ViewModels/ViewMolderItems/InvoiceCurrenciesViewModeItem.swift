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
    
    var currencies: [InvoiceSettingModel]
    
    init(currencies: [InvoiceSettingModel]) {
        self.currencies = currencies
    }
}
