import Foundation

class NetworkConfig {
    public static let shared = NetworkConfig()
    
    #if DEBUG
    public var baseServerURL = BaseServerURLs.dev.getURL()
    public var notificationHubSettings = PushNotificationHubSettings.dev

    #else
    public var baseServerURL = BaseServerURLs.prod.getURL()
    public var notificationHubSettings = PushNotificationHubSettings.prod
    #endif
}
internal enum CertificateNames: String, EnumCollection {
    case lykkexnettest
    case lykkexnet
    case lykkecomprod

    internal func value() -> String {
        return self.rawValue
    }
}

internal enum BaseServerURLs: String, EnumCollection {
    case dev
    case test
    case prod

    internal func getURL() -> String {
        switch self {
        case .dev:
            return "https://pay-api-dev.lykkex.net/api/v1/mobile"
        case .test:
            return "https://pay-api-test.lykkex.net/api/v1/mobile"
        case .prod:
            return "https://payment-api.lykke.com/api/v1/mobile"
        }
    }

    internal func value() -> String {
        return self.rawValue
    }
}

protocol EnumCollection : Hashable {}

extension EnumCollection {
    static func allCases() -> AnySequence<Self> {
        typealias S = Self
        return AnySequence { () -> AnyIterator<S> in
            var raw = 0
            return AnyIterator {
                let current : Self = withUnsafePointer(to: &raw) { $0.withMemoryRebound(to: S.self, capacity: 1) { $0.pointee } }
                guard current.hashValue == raw else { return nil }
                raw += 1
                return current
            }
        }
    }
}
