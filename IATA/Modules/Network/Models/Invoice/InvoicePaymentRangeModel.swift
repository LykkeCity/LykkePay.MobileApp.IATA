import ObjectMapper

class InvoicePaymentRangeItemModel: Mappable {
    
    private enum PropertyKey: String {
        case min
        case max
    }
    
    internal var min: Int32?
    internal var max: Int32?
    
    internal required init?(map: Map) {
    }
    
    internal init(min: Int32?, max: Int32?) {
        self.min = min
        self.max = max
    }
    
    
    internal func mapping(map: Map) {
        min <- map[PropertyKey.min.rawValue]
        max <- map[PropertyKey.max.rawValue]
    }
}
