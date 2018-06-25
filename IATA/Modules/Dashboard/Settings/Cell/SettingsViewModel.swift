import ObjectMapper

class SettingsViewModel: Mappable {

    internal var merchantName: String?

    internal var merchantLogoUrl: String?

    internal var firstName: String?

    internal var lastName: String?

    internal var email: String?

    internal init() {}

    internal init(settings: SettingsModel) {
        self.merchantName = settings.merchantName
        self.merchantLogoUrl = settings.merchantLogoUrl
        self.firstName = settings.firstName
        self.lastName = settings.lastName
        self.email = settings.email
    }

    required init?(map: Map) { }

    func mapping(map: Map) { }

}
