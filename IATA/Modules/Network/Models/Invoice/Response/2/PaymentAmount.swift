import ObjectMapper

class PaymentAmount: Mappable {
    
    private enum PropertyKey: String {
        case amountToPay
    }
    
    internal var amountToPay: Double?
    
    internal required init?() {
    }
    
    required init?(map: Map) {
        
    }
    
    internal func mapping(map: Map) {
        self.amountToPay <- map[PropertyKey.amountToPay.rawValue]
    }
}
