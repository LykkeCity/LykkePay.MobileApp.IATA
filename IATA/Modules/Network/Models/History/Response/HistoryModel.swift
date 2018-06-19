import Foundation
import UIKit
import ObjectMapper

class HistoryModel: Mappable, Reflectable {
    
    private enum PropertyKey: String {
        case id
        case logo
        case title
        case timeStamp
        case amount
        case assetId
        
        case symbol
    }
    
    internal var id: String?
    internal var logo: String?
    internal var title: String?
    internal var timeStamp: String?
    internal var amount: String?
    internal var assetId: String?
    internal var symbol: String?
    
    
    internal required init?(map: Map) {
    }
    
    internal init() {}
    
    init(json: [String: Any]) {
        
    }
    
    internal func mapping(map: Map) {
        self.id <- map[PropertyKey.id.rawValue]
        self.logo <- map[PropertyKey.logo.rawValue]
        self.title <- map[PropertyKey.title.rawValue]
        self.timeStamp <- map[PropertyKey.timeStamp.rawValue]
        self.amount <- map[PropertyKey.amount.rawValue]
        self.assetId <- map[PropertyKey.assetId.rawValue]
        
        if let timeStamp = self.timeStamp {
            self.timeStamp = DateUtils.formatDateFromFormat(dateString: timeStamp)
        }
        
        if let asset = assetId {
            if (asset.contains("USD")) {
                self.symbol = "$"
            } else {
                self.symbol = "€"
            }
        }
    }
}

