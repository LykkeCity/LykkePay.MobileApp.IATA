import Foundation
import UIKit
import ObjectMapper

class ExchangeModel: Mappable {

    private enum PropertyKey: String {
        case sourceAssetId
        case sourceAmount
        case destAssetId
        case destAmount
        case rate
    }

    var sourceAssetId: String?
    var sourceAmount: Double?
    var destAssetId: String?
    var destAmount: Double?
    var rate: Double?



    internal required init?(map: Map) {
    }

    internal init() {}

    init(json: [String: Any]) {

    }

    internal func mapping(map: Map) {
        sourceAssetId <- map[PropertyKey.sourceAssetId.rawValue]
        sourceAmount <- map[PropertyKey.sourceAmount.rawValue]
        destAssetId <- map[PropertyKey.destAssetId.rawValue]
        rate <- map[PropertyKey.rate.rawValue]
    }
}


