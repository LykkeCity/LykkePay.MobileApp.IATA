import Foundation
import ObjectMapper

class CancelDisputInvoiceRequest: Mappable {

    public enum PropertyKey: String {
        case invoiceId
    }

    var invoiceId: String?

    internal required init?() {

    }
    required init?(map: Map) {

    }

    internal func mapping(map: Map) {
        invoiceId <- map[PropertyKey.invoiceId.rawValue]
    }
}



