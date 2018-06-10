import ObjectMapper

class InvoiceSettingAirlinesModel: Mappable {
    
    private enum PropertyKey: String {
        case name
        case logo
        case checked
        case type
    }
    
    internal var name: String?
    internal var logo: String?
    internal var checked: Bool?
    internal var type: String?
    
    internal required init?(map: Map) {
    }
    
    init(json: [String: Any]) {
        self.name = json["name"] as? String
        self.logo = json["logo"] as? String
        self.checked = json["checked"] as? Bool
        self.type = json["type"] as? String
    }
    
    internal func mapping(map: Map) {
        name <- map[PropertyKey.name.rawValue]
        logo <- map[PropertyKey.logo.rawValue]
        checked <- map[PropertyKey.checked.rawValue]
        type <- map[PropertyKey.type.rawValue]
    }
}
