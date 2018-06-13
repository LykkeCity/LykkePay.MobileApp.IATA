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
            self.init(type: type, color: Theme.shared.greyStatusColor, title: "Invoice.Status.Items.Dispute".localize(), isCanBePaid: true)
            break
        case .InProgress:
            self.init(type: type, color: Theme.shared.blueProgressStatusColor, title: "Invoice.Status.Items.InProgress".localize(), isCanBePaid: false)
            break
        case .Paid:
            self.init(type: type, color: Theme.shared.greenColor, title: "Invoice.Status.Items.Paid".localize(), isCanBePaid: false)
            break
        case .Underpaid:
            self.init(type: type, color: Theme.shared.greenColor, title: "Invoice.Status.Items.Underpaid".localize(), isCanBePaid: true)
            break
        case .Overpaid:
            self.init(type: type, color: Theme.shared.redErrorStatusColor, title: "Invoice.Status.Items.Overpaid".localize(), isCanBePaid: false)
            break
        case .LatePaid:
            self.init(type: type, color: Theme.shared.redErrorStatusColor, title: "Invoice.Status.Items.Latepaid".localize(), isCanBePaid: false)
            break
        case .InternalError:
            self.init(type: type, color: Theme.shared.redErrorStatusColor, title: "Invoice.Status.Items.InternalError".localize(), isCanBePaid: false)
            break
        case .PastDue:
            self.init(type: type, color: Theme.shared.redErrorStatusColor, title: "Invoice.Status.Items.PastDue".localize(), isCanBePaid: false)
            break
        default:
            self.init(type: type, color: Theme.shared.greyStatusColor, title: "Invoice.Status.Items.Dispute".localize(), isCanBePaid: false)
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
