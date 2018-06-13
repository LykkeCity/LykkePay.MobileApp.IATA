import Foundation

class InvoiceSettlementPeriodViewModeItem: InvoiceViewModelItem {
    
    var type: InvoiceViewModelItemType {
        return .settlementPeriod
    }
    
    var sectionTitle: String {
        return "Invoice.Settings.SettlementPeriod.Title".localize()
    }
    
    var rowCount: Int {
        return settlementPeriod.count
    }
    
    var settlementPeriod: [InvoiceSettingModel]
    
    init(settlementPeriod: [InvoiceSettingModel]) {
        self.settlementPeriod = settlementPeriod
    }
}
