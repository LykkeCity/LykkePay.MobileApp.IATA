import Foundation
import UIKit
import ObjectMapper

class HistoryModel: Mappable {
    
    private enum PropertyKey: String {
        case logo
        case name
        case settlementPeriod
        case amount
    }
    
    internal var logo: String?
    internal var name: String?
    internal var settlementPeriod: String?

    
    internal required init?(map: Map) {
    }
    
    internal init() {}
    
    init(json: [String: Any]) {
       
    }
    
    internal func mapping(map: Map) {
    }
}

