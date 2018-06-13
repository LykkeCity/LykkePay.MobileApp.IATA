import Foundation
import PromiseKit

protocol InvoiceState {
    
    func mapping(jsonString: String!) -> [InvoiceModel]
    func getInvoiceStringJson() -> Promise<String>
    func getMenuItems() -> [String]
    func recalculateAmount(isSelected: Bool, model: InvoiceModel) -> Double
    func resultAmount() -> Double
    func getCountSelected() -> Int
    func selectedStatus(index: Int)
    func isCanBeOpenDispute(model: InvoiceModel) -> Bool
    func isCanBeClosedDispute(model: InvoiceModel) -> Bool
    func isChecked(model: InvoiceModel) -> Bool
}
