import Foundation
import UIKit
import ObjectMapper

class DisputeModel: Mappable {
    
    private enum PropertyKey: String {
        case invoice
        case reason
        case disputeRaisedAt
    }
    
    internal var invoice: InvoiceModel?
    internal var reason: String?
    internal var disputeRaisedAt: String?
    
    internal required init?(map: Map) {
    }
    
    internal init() {}
    
    init(json: [String: Any]) {
        self.invoice = json[PropertyKey.invoice.rawValue] as? InvoiceModel
        self.reason = json[PropertyKey.reason.rawValue] as? String
        self.disputeRaisedAt = json[PropertyKey.disputeRaisedAt.rawValue] as? String
    }
    
    internal func mapping(map: Map) {
        self.invoice <- map[PropertyKey.invoice.rawValue]
        self.reason <- map[PropertyKey.reason.rawValue]
        self.disputeRaisedAt <- map[PropertyKey.disputeRaisedAt.rawValue]
    }
}

