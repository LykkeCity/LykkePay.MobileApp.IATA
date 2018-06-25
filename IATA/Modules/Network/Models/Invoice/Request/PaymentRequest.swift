import Foundation
import ObjectMapper

class PaymentRequest:  Mappable {
    public enum PropertyKey: String {
        case invoicesIds
        case amountInBaseAsset
    }
    
    var invoicesIds: [String]? = []
    var amountInBaseAsset: Double?
    
    internal required init?() {
    }
    
    required init?(map: Map) {
        
    }
    
    internal func mapping(map: Map) {
        amountInBaseAsset <- map[PropertyKey.amountInBaseAsset.rawValue]
        invoicesIds <- map[PropertyKey.invoicesIds.rawValue]
    }
    
}
