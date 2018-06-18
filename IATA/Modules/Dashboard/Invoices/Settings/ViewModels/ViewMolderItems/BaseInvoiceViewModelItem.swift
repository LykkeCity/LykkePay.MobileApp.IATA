import Foundation


class BaseInvoiceViewModelItem: InvoiceViewModelItem {
    var items: [InvoiceSettingAirlinesModel]
    var type = InvoiceViewModelItemType.airlines
    
    func getType() -> InvoiceViewModelItemType? {
        return type
    }
    
    func setType(type: InvoiceViewModelItemType) {
        self.type = type
    }
    
    func getSectionTitle() -> String? {
        return nil
    }
    
    init(items: [InvoiceSettingAirlinesModel]) {
        self.items = items
    }
    
    func rowCount() -> Int {
        return self.items.count
    }
}

