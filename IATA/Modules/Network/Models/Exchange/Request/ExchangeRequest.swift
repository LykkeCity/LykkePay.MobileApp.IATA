import Foundation
import ObjectMapper

class ExchangeRequest:  Mappable {

    public enum PropertyKey: String {
        case sourceAssetId
        case sourceAmount
        case destAssetId
        case expectedRate
    }

    var sourceAssetId: String?
    var sourceAmount: Double?
    var destAssetId: String?
    var expectedRate: Double?

    internal required init() {
    }

    required init(map: Map) {

    }

    internal func mapping(map: Map) {
        sourceAssetId <- map[PropertyKey.sourceAssetId.rawValue]
        sourceAmount <- map[PropertyKey.sourceAmount.rawValue]
        destAssetId <- map[PropertyKey.destAssetId.rawValue]
        expectedRate <- map[PropertyKey.expectedRate.rawValue]
    }

}
