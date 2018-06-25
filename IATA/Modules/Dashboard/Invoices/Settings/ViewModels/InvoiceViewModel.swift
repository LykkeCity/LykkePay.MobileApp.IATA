import Foundation
import UIKit
import PromiseKit

protocol InvoiceViewModelItem {
    func getType() -> InvoiceViewModelItemType?
    func getSectionTitle() -> String?
    func rowCount() -> Int
    func setType(type: InvoiceViewModelItemType)
}

class InvoiceViewModel: NSObject {
    var state: InvoiceSettingsState = DefaultInvoiceSettingsState() as InvoiceSettingsState
    
    internal override init() {
        super.init()
    }
    
    func scrollToLastPosition(tableView: UITableView) {
        let y = tableView.contentSize.height - tableView.frame.size.height + 250
        tableView.setContentOffset(CGPoint(x: 0, y: (y<0) ? 0 : y), animated: true)
    }
}
