import ObjectMapper

class SettingsModel: Mappable {

    private enum PropertyKey: String {
        case merchantName
        case merchantLogoUrl
        case firstName
        case lastName
        case email
        case isInternalSupervisor
    }

    internal var merchantName: String?
    internal var merchantLogoUrl: String?
    internal var firstName: String?
    internal var lastName: String?
    internal var email: String?
    internal var isInternalSupervisor: Bool?

    internal required init?(map: Map) {
    }

    internal init() {}

    internal func mapping(map: Map) {
        merchantName <- map[PropertyKey.merchantName.rawValue]
        merchantLogoUrl <- map[PropertyKey.merchantLogoUrl.rawValue]
        firstName <- map[PropertyKey.firstName.rawValue]
        lastName <- map[PropertyKey.lastName.rawValue]
        email <- map[PropertyKey.email.rawValue]
        isInternalSupervisor <- map[PropertyKey.isInternalSupervisor.rawValue]
    }
}
