
import Foundation
import ObjectMapper

class CashOutRequest: Mappable {
    
    public enum PropertyKey: String {
        case assetId
        case amount
        case desiredCashoutAsset
    }
    
    var assetId: String?
    var amount: NSDecimalNumber?
    var desiredCashoutAsset: String?
    
    internal required init() {
    }
    
    required init(map: Map) {
        
    }
    
    internal func mapping(map: Map) {
        assetId <- map[PropertyKey.assetId.rawValue]
        amount <- map[PropertyKey.amount.rawValue]
        desiredCashoutAsset <- map[PropertyKey.desiredCashoutAsset.rawValue]
    }
    
}

