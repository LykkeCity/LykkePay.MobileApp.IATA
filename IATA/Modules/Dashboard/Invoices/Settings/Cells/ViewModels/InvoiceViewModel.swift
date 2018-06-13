import Foundation
import UIKit

protocol InvoiceViewModelItem {
    var type: InvoiceViewModelItemType { get }
    var sectionTitle: String { get }
    var rowCount: Int { get }
}

class InvoiceViewModel: NSObject {
    var state: InvoiceSettingsState = DefaultInvoiceSettingsState() as InvoiceSettingsState
    
    override init() {
        super.init()
        guard let data = dataFromFile("ServerData"), let model = InvoiceScreenModel(data: data) else {
            return
        }
        
        self.state.initItems(model: model)
    }
}
