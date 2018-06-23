import Foundation
import UIKit
import PromiseKit

protocol InvoiceSettingsState {
    func stateChanged(isSelected: Bool, item: Any)
    func clickDone()
    func getItems() -> [InvoiceViewModelItem]
    func initItems(model: FiltersInvoiceList)
    func getHeight(indexPath: IndexPath) -> CGFloat!
    func updatePaymentRangeMax(max: Int?)
    func updatePaymentRangeMin(min: Int?)
    func getFilters() -> Promise<FiltersInvoiceList>
}
