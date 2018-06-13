import ObjectMapper

class InvoiceSettingModel: Mappable {
    
    private enum PropertyKey: String {
        case name
        case checked
        case type
    }
    
    internal var name: String?
    internal var checked: Bool?
    internal var type: String?
    
    internal required init?(map: Map) {
    }
    
    internal init() {}
    
    init(json: [String: Any]) {
        self.name = json["name"] as? String
        self.checked = json["checked"] as? Bool
        self.type = json["type"] as? String
    }
        
    internal func mapping(map: Map) {
        name <- map[PropertyKey.name.rawValue]
        checked <- map[PropertyKey.checked.rawValue]
        type <- map[PropertyKey.type.rawValue]
    }
}
