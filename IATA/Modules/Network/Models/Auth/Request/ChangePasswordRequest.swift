import ObjectMapper

class ChangePasswordRequest: Mappable {
    
    private enum PropertyKey: String {
        case currentPasssword
        case newPasswordHash
    }
    
    internal var newPasswordHash: String?
    internal var currentPasssword: String?
    
    init() {
    }
    
    internal required init?(map: Map) {
    }
    
    internal func mapping(map: Map) {
        currentPasssword <- map[PropertyKey.currentPasssword.rawValue]
        newPasswordHash <- map[PropertyKey.newPasswordHash.rawValue]
    }
}
