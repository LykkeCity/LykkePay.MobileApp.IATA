import ObjectMapper

class InvoiceSettingPaymentRangeItemModel: Mappable {
    
    private enum PropertyKey: String {
        case min
        case max
        case maxRangeInBaseAsset
    }
    
    internal var min: Int?
    internal var max: Int?
    internal var maxRangeInBaseAsset: Double?
    
    internal required init?(map: Map) {
    }
    
    internal required init?() {}
    
    internal init(min: Int?, max: Int?, maxRangeInBaseAsset: Double?) {
        self.min = min
        self.max = max
        self.maxRangeInBaseAsset = maxRangeInBaseAsset
    }
    
    
    internal func mapping(map: Map) {
        min <- map[PropertyKey.min.rawValue]
        max <- map[PropertyKey.max.rawValue]
    }
}
