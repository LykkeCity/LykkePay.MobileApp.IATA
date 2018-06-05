import Foundation

class NetworkConfig {
    public static let shared = NetworkConfig()
    
    #if DEBUG
    public let baseServerURL = "https://pay-api-test.lykkex.net"
    #else
    public let baseServerURL = "https://pay-api-test.lykkex.net"
    #endif
    
    
    public let tokenSignIn = "/api/v1/mobile/auth"

}
