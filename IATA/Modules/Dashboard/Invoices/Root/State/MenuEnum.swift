import Foundation

struct Menu {
    var type: MenuEnum
    var title: String
    var isActive: Bool
}

enum MenuEnum: String{
    case All
    case Paid
    case Unpaid
    case Dispute
}
