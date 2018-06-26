import Foundation
import ObjectMapper

class ModelErrors {
    
    public enum PropertyKey: String {
        case email
        case password
        case currentPassword
    }
    
    internal var email: [String]?
    internal var password: [String]?
    internal var currentPassword: [String]?
    
    internal required init?(map: Map) {
    }
    
    internal required init?(json: [String: Any]?) {
        self.email = json![PropertyKey.email.rawValue] as! [String]?
        self.password = json![PropertyKey.password.rawValue] as! [String]?
        self.currentPassword  = json![PropertyKey.currentPassword.rawValue] as! [String]?
    }
    
    
    internal func mapping(map: Map) {
        email <- map[PropertyKey.email.rawValue]
        password <- map[PropertyKey.password.rawValue]
        currentPassword <- map[PropertyKey.currentPassword.rawValue]
    }
}
