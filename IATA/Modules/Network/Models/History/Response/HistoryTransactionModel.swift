import Foundation
import UIKit
import ObjectMapper

class HistoryTransactionModel: Mappable, Reflectable {
    
    private struct PropertyKeyTitle {
        var title: String?
        var key: PropertyKey
        
        init(key: PropertyKey) {
            self.key = key
            self.title = self.getTitle()
        }
        
        func getTitle() -> String? {
            switch key {
            case .logo:
                return nil
            default:
                return "tesp3"
            }
        }
    }
    
    private enum PropertyKey: String {
        case id
        case logo
        case title
        case timeStamp
        case amount
        case assetId
        case soldBy
        case blockHeight
        case blockConfirmations
        case txHash
    }
    
    internal var id: String?
    internal var logo: String?
    internal var title: String?
    internal var timeStamp: Int?
    internal var amount: String?
    internal var assetId: String?
    internal var soldBy: String?
    internal var blockHeight: String?
    internal var blockConfirmations: String?
    internal var txHash: String?
    
    
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
        self.soldBy <- map[PropertyKey.soldBy.rawValue]
        self.blockHeight <- map[PropertyKey.blockHeight.rawValue]
        self.blockConfirmations <- map[PropertyKey.blockConfirmations.rawValue]
        self.txHash <- map[PropertyKey.txHash.rawValue]
    }
    
    func valueFor() -> [String : Any] {
        var params = [String : Any]()
        let mirror = Mirror(reflecting: self)
        for (name, value) in mirror.children {
            guard let name = name else { continue }
            let structInfo = PropertyKeyTitle(key: PropertyKey(rawValue: name)!)
            if let title = structInfo.title {
                params[title] = value
            }
            
        }
        return params
    }
}

protocol Reflectable {
    func properties() -> [String]
}

extension Reflectable {
    func properties() -> [String]{
        var s = [String]()
        for c in Mirror(reflecting: self).children {
            if let name = c.label {
                s.append(name)
            }
        }
        return s
    }
}
