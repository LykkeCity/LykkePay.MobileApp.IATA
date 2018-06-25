import ObjectMapper

class InvoiceFiltersModel: Mappable {
    
    private enum PropertyKey: String {
        case value
        case merchantLogoUrl
        case checked
        case type
        case id
        case symbol
    }
    
    internal var value: String?
    internal var merchantLogoUrl: String?
    internal var checked: Bool? = false
    internal var type: String?
    internal var id: String?
    internal var symbol: String?
    
    internal required init?(map: Map) {
    }
    
    internal required init?() {
    }
    
    init(json: [String: Any]) {
        self.value = json[PropertyKey.value.rawValue] as? String
        self.merchantLogoUrl = json[PropertyKey.merchantLogoUrl.rawValue] as? String
        self.checked = json[PropertyKey.checked.rawValue] as? Bool
        self.type = json[PropertyKey.type.rawValue] as? String
        self.id = json[PropertyKey.id.rawValue] as? String
        self.initSymbol()
    }
    
    internal func mapping(map: Map) {
        self.value <- map[PropertyKey.value.rawValue]
        self.merchantLogoUrl <- map[PropertyKey.merchantLogoUrl.rawValue]
        self.checked <- map[PropertyKey.checked.rawValue]
        self.type <- map[PropertyKey.type.rawValue]
        self.id <- map[PropertyKey.id.rawValue]
        self.initSymbol()
    }
    
    internal func initSymbol() {
        if let idValue = id, idValue.contains("USD") {
            self.symbol = "$"
        } else {
            self.symbol = "€"
        }
    }
}
