import ObjectMapper

class SettingsMerchantsModel: Mappable {

    private enum PropertyKey: String {
        case id
        case value
        case isSelected
    }

    internal var id: String?
    internal var value: String?
    internal var isSelected: Bool?
    internal var symbol: String?


    internal required init?(map: Map) {
    }

    internal init() {}

    internal func mapping(map: Map) {
        id <- map[PropertyKey.id.rawValue]
        value <- map[PropertyKey.value.rawValue]
        isSelected <- map[PropertyKey.isSelected.rawValue]
        initSymbol()
    }

    private func initSymbol() {
        if let value = value, value.isUsd() {
            self.symbol = "$"
        } else {
            self.symbol = "€"
        }
    }
}
