import Foundation
import UIKit

struct InvoiceStatusesStruct {
    var type: InvoiceStatuses
    var colorStatus: UIColor
    var color: UIColor
    var title: String
    var isCanBePaid: Bool
    
    init(type:InvoiceStatuses, colorStatus: UIColor, color:UIColor, title:String, isCanBePaid: Bool) {
        self.type = type
        self.color = color
        self.title = title
        self.colorStatus = colorStatus
        self.isCanBePaid = isCanBePaid
    }
    
    init(type:InvoiceStatuses) {
        switch type {
        case .Unpaid:
            self.init(type: type, colorStatus: Theme.shared.blueProgressStatusColor, color: Theme.shared.greenColor, title: R.string.localizable.invoiceStatusItemsUnpaid(), isCanBePaid: true)
            break
        case .InProgress:
            self.init(type: type, colorStatus: Theme.shared.blueProgressStatusColor, color: Theme.shared.greenColor, title: R.string.localizable.invoiceStatusItemsInProgress(), isCanBePaid: false)
            break
        case .Paid:
            self.init(type: type, colorStatus: Theme.shared.greenColor, color: Theme.shared.greenColor, title: R.string.localizable.invoiceStatusItemsPaid(), isCanBePaid: false)
            break
        case .Underpaid:
            self.init(type: type, colorStatus: Theme.shared.partiallyPaidStatusColor, color: Theme.shared.greenColor, title: R.string.localizable.invoiceStatusItemsUnderpaid(), isCanBePaid: true)
            break
        case .Overpaid:
            self.init(type: type, colorStatus: Theme.shared.redErrorStatusColor, color: Theme.shared.redErrorStatusColor, title: R.string.localizable.invoiceStatusItemsOverpaid(), isCanBePaid: false)
            break
        case .LatePaid:
            self.init(type: type, colorStatus: Theme.shared.redErrorStatusColor, color: Theme.shared.redErrorStatusColor, title: R.string.localizable.invoiceStatusItemsLatepaid(), isCanBePaid: false)
            break
        case .InternalError:
            self.init(type: type, colorStatus: Theme.shared.redErrorStatusColor, color: Theme.shared.redErrorStatusColor, title: R.string.localizable.invoiceStatusItemsInternalError(), isCanBePaid: false)
            break
        case .PastDue:
            self.init(type: type, colorStatus: Theme.shared.redErrorStatusColor, color: Theme.shared.greyStatusColor, title: R.string.localizable.invoiceStatusItemsPastDue(), isCanBePaid: false)
            break
        default:
            self.init(type: type, colorStatus: Theme.shared.greyStatusColor,  color: Theme.shared.greyStatusColor, title: R.string.localizable.invoiceStatusItemsDispute(), isCanBePaid: false)
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
