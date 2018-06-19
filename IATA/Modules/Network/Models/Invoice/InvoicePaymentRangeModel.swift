import ObjectMapper

class InvoiceSettingPaymentRangeItemModel: Mappable {
    
    private enum PropertyKey: String {
        case min
        case max
    }
    
    internal var min: Int?
    internal var max: Int?
    
    internal required init?(map: Map) {
    }
    
    internal init(min: Int?, max: Int?) {
        self.min = min
        self.max = max
    }
    
    
    internal func mapping(map: Map) {
        min <- map[PropertyKey.min.rawValue]
        max <- map[PropertyKey.max.rawValue]
    }
}
