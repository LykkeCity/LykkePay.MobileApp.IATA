import ObjectMapper

class PinValidationResponse: Mappable {
    
    private enum PropertyKey: String {
        case passed
    }
    
    internal var passed: Bool?
    
    internal required init?(map: Map) {
    }
    
    internal func mapping(map: Map) {
        passed <- map[PropertyKey.passed.rawValue]
    }
}
