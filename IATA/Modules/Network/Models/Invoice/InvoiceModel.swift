import ObjectMapper

class InvoiceModel: Mappable {
    
    private enum PropertyKey: String {
        case name
        case checked
    }
    
    internal var name: String?
    internal var checked: Bool?
    
    internal required init?(map: Map) {
    }
    
    internal init() {}
    
    init(json: [String: Any]) {
        self.name = json["name"] as? String
        self.checked = json["checked"] as? Bool
    }
        
    internal func mapping(map: Map) {
        name <- map[PropertyKey.name.rawValue]
        checked <- map[PropertyKey.checked.rawValue]
    }
}
