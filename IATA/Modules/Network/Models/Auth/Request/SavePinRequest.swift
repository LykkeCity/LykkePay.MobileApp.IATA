import ObjectMapper

class SavePinRequest: Mappable {
    
    private enum PropertyKey: String {
        case newPinCodeHash
    }
    
    internal var newPinCodeHash: String?
    
    init() {
    }
    
    internal required init?(map: Map) {
    }
    
    internal func mapping(map: Map) {
        newPinCodeHash <- map[PropertyKey.newPinCodeHash.rawValue]
    }
}
