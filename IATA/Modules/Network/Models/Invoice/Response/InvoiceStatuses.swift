import Foundation

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
