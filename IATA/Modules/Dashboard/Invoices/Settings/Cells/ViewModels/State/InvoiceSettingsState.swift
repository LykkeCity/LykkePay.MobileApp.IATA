import Foundation
import UIKit

protocol InvoiceSettingsState {
    func stateChanged(isSelected: Bool, item: Any)
    func clickDone()
    func getItems() -> [InvoiceViewModelItem]
    func initItems(model: InvoiceScreenModel)
    func getHeight(indexPath: IndexPath) -> CGFloat!
}
