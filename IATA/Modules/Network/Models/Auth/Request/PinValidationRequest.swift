import ObjectMapper

class PinValidationRequest: Mappable {
    
    private enum PropertyKey: String {
        case pinCode
    }
    
    internal var pinCode: String?
    
    init() {
    }
    
    internal required init?(map: Map) {
    }
    
    internal func mapping(map: Map) {
        pinCode <- map[PropertyKey.pinCode.rawValue]
    }
}
