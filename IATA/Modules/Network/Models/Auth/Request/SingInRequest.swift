import ObjectMapper

class SignInRequest: Mappable {
    
    private enum PropertyKey: String {
        case email
        case password
    }
    
    internal var email: String?
    internal var password: String?
    
    init() {
    }
    
    internal required init?(map: Map) {
    }
    
    internal func mapping(map: Map) {
        email <- map[PropertyKey.email.rawValue]
        password <- map[PropertyKey.password.rawValue]
    }
}
