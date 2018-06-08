import ObjectMapper

class AirlinesInvoiceModel: Mappable {
    
    private enum PropertyKey: String {
        case name
        case logo
        case checked
    }
    
    internal var name: String?
    internal var logo: String?
    internal var checked: Bool?
    
    internal required init?(map: Map) {
    }
    
    init(json: [String: Any]) {
        self.name = json["name"] as? String
        self.logo = json["logo"] as? String
        self.checked = json["checked"] as? Bool
    }
    
    internal func mapping(map: Map) {
        name <- map[PropertyKey.name.rawValue]
        logo <- map[PropertyKey.logo.rawValue]
        checked <- map[PropertyKey.checked.rawValue]
    }
}
