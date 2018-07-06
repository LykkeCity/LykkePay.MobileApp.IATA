import ObjectMapper

class PinValidationResponse: Mappable {
    
    private enum PropertyKey: String {
        case passed
        case notificationIds
    }
    
    internal var passed: Bool?
    internal var notificationIds: NotificationIds?
    
    internal required init?(map: Map) {
    }
    
    internal func mapping(map: Map) {
        passed <- map[PropertyKey.passed.rawValue]
        notificationIds <- map[PropertyKey.notificationIds.rawValue]
    }
}
