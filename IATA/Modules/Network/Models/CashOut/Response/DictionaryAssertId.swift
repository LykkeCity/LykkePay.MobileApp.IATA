
import Foundation
import ObjectMapper

class DictionaryAssertId: Mappable {
    
    enum PropertyKey: String {
        case name
    }
    
    var name: String?
    var isSelected: Bool?
    
    internal required init?(map: Map) {
    }
    
    internal init() {}
    
    init(json: [String: Any]) {
        
    }
    
    internal func mapping(map: Map) {
        name <- map[PropertyKey.name.rawValue]
        if let nameAssert = name, nameAssert.isUsd() {
            self.isSelected = true
        } else {
            self.isSelected = false
        }
    }
}
