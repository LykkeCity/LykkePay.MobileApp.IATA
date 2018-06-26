import Foundation
import ObjectMapper

class DisputInvoiceRequest: Mappable {

    public enum PropertyKey: String {
        case invoiceId
        case reason
    }

    var invoiceId: String?
    var reason: String?

    internal required init?() {

    }
    required init?(map: Map) {

    }

    internal func mapping(map: Map) {
        invoiceId <- map[PropertyKey.invoiceId.rawValue]
        reason <- map[PropertyKey.reason.rawValue]
    }
}


