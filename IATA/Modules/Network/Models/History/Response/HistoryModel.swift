import Foundation
import UIKit
import ObjectMapper

class HistoryModel: Mappable {
    
    private enum PropertyKey: String {
        case id
        case merchantLogoUrl
        case title
        case createdOn
        case amount
        case assetId
        
        case symbol
    }
    
    internal var id: String?
    internal var logo: String?
    internal var title: String?
    internal var timeStamp: String?
    internal var amount: Int?
    internal var assetId: String?
    internal var symbol: String?
    
    
    internal required init?(map: Map) {
    }
    
    internal init() {}
    
    init(json: [String: Any]) {
        
    }
    
    internal func mapping(map: Map) {
        self.id <- map[PropertyKey.id.rawValue]
        self.logo <- map[PropertyKey.merchantLogoUrl.rawValue]
        self.title <- map[PropertyKey.title.rawValue]
        self.timeStamp <- map[PropertyKey.createdOn.rawValue]
        self.amount <- map[PropertyKey.amount.rawValue]
        self.assetId <- map[PropertyKey.assetId.rawValue]
        
        if let timeStamp = self.timeStamp {
            self.timeStamp = DateUtils.formatDateFromFormat(dateString: timeStamp)
        }
        
        if let asset = assetId {
            if (asset.isUsd()) {
                self.symbol = "$"
            } else {
                self.symbol = "€"
            }
        }
    }
}

