import Foundation

class NetworkConfig {
    public static let shared = NetworkConfig()
    
    #if DEBUG
    public let baseServerURL = BaseServerURLs.dev.getURL()

    #else
    public let baseServerURL = BaseServerURLs.dev.getURL()
    #endif
}

public enum CertificateNames: String, EnumCollection {
    case lykkexnettest
    case lykkexnet

    internal func value() -> String {
        return self.rawValue
    }
}

public enum BaseServerURLs {
    case dev
    case test

    internal func getURL() -> String {
        switch self {
        case .dev:
            return "https://pay-api-dev.lykkex.net/api/v1/mobile"
        case .test:
            return "https://pay-api-test.lykkex.net/api/v1/mobile"
        }
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
