import ObjectMapper

class InvoiceSettingAirlinesModel: Mappable {
    
    private enum PropertyKey: String {
        case name
        case logo
        case checked
        case type
        case id
    }
    
    internal var name: String?
    internal var logo: String?
    internal var checked: Bool?
    internal var type: String?
    internal var id: String?
    
    internal required init?(map: Map) {
    }
    
    init(json: [String: Any]) {
        self.name = json[PropertyKey.name.rawValue] as? String
        self.logo = json[PropertyKey.logo.rawValue] as? String
        self.checked = json[PropertyKey.checked.rawValue] as? Bool
        self.type = json[PropertyKey.type.rawValue] as? String
        self.id = json[PropertyKey.id.rawValue] as? String
    }
    
    internal func mapping(map: Map) {
        name <- map[PropertyKey.name.rawValue]
        logo <- map[PropertyKey.logo.rawValue]
        checked <- map[PropertyKey.checked.rawValue]
        type <- map[PropertyKey.type.rawValue]
        id <- map[PropertyKey.id.rawValue]
    }
}
