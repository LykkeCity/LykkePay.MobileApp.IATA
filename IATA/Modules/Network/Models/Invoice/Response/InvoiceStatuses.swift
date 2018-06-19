import Foundation
import UIKit

struct InvoiceStatusesStruct {
    var type: InvoiceStatuses?
    var color: UIColor?
    var title: String?
    var isCanBePaid: Bool?
    
    init(type:InvoiceStatuses, color:UIColor, title:String, isCanBePaid: Bool) {
        self.type = type
        self.color = color
        self.title = title
        self.isCanBePaid = isCanBePaid
    }
    
    init(type:InvoiceStatuses) {
        switch type {
        case .Unpaid:
            self.init(type: type, color: Theme.shared.greyStatusColor, title: R.string.localizable.invoiceStatusItemsDispute(), isCanBePaid: true)
            break
        case .InProgress:
            self.init(type: type, color: Theme.shared.blueProgressStatusColor, title: R.string.localizable.invoiceStatusItemsInProgress(), isCanBePaid: false)
            break
        case .Paid:
            self.init(type: type, color: Theme.shared.greenColor, title: R.string.localizable.invoiceStatusItemsPaid(), isCanBePaid: false)
            break
        case .Underpaid:
            self.init(type: type, color: Theme.shared.greenColor, title: R.string.localizable.invoiceStatusItemsUnderpaid(), isCanBePaid: true)
            break
        case .Overpaid:
            self.init(type: type, color: Theme.shared.redErrorStatusColor, title: R.string.localizable.invoiceStatusItemsOverpaid(), isCanBePaid: false)
            break
        case .LatePaid:
            self.init(type: type, color: Theme.shared.redErrorStatusColor, title: R.string.localizable.invoiceStatusItemsLatepaid(), isCanBePaid: false)
            break
        case .InternalError:
            self.init(type: type, color: Theme.shared.redErrorStatusColor, title: R.string.localizable.invoiceStatusItemsInternalError(), isCanBePaid: false)
            break
        case .PastDue:
            self.init(type: type, color: Theme.shared.redErrorStatusColor, title: R.string.localizable.invoiceStatusItemsPastDue(), isCanBePaid: false)
            break
        default:
            self.init(type: type, color: Theme.shared.greyStatusColor, title: R.string.localizable.invoiceStatusItemsDispute(), isCanBePaid: false)
            break
        }
    }
}

enum InvoiceStatuses: String {
    case all
    case Unpaid
    case InProgress
    case Paid
    case Underpaid
    case Overpaid
    case LatePaid
    case InternalError
    case PastDue
}
