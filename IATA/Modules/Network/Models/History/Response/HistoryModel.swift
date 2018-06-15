import Foundation
import UIKit
import ObjectMapper

class HistoryModel: Mappable, Reflectable {
    
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
            case .settlementPeriod:
                return "tses2"
            default:
                return "tesp3"
            }
        }
    }
        
    private enum PropertyKey: String {
        case logo
        case name
        case settlementPeriod
        case amount
        
        case soldBy
        case timeStamp
    }
    
    internal var logo: String?
    internal var name: String?
    internal var settlementPeriod: String?
    internal var amount: Int?
    internal var soldBy: String?
    internal var timeStamp: String?
    
    
    internal required init?(map: Map) {
    }
    
    internal init() {}
    
    init(json: [String: Any]) {
        
    }
    
    internal func mapping(map: Map) {
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


