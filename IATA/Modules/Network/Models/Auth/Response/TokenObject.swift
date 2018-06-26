import ObjectMapper

class TokenObject: Mappable {
    
    private enum PropertyKey: String {
        case token
        case forcePasswordUpdate
        case ForcePinUpdate
    }
    
    internal var token: String?
    internal var forcePasswordUpdate: Bool?
    internal var forceUpdatePin: Bool?
    
    internal required init?(map: Map) {
    }
    
    internal func mapping(map: Map) {
        token <- map[PropertyKey.token.rawValue]
        forcePasswordUpdate <- map[PropertyKey.forcePasswordUpdate.rawValue]
        forceUpdatePin <- map[PropertyKey.ForcePinUpdate.rawValue]
    }
}
