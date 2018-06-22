import Foundation
import UIKit

protocol InvoiceViewModelItem {
    func getType() -> InvoiceViewModelItemType?
    func getSectionTitle() -> String?
    func rowCount() -> Int
    func setType(type: InvoiceViewModelItemType)
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
    
    func scrollToLastPosition(tableView: UITableView) {
        let y = tableView.contentSize.height - tableView.frame.size.height + 250
        tableView.setContentOffset(CGPoint(x: 0, y: (y<0) ? 0 : y), animated: true)
    }
}
