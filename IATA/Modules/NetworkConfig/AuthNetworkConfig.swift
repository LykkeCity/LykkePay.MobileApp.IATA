import Foundation

class AuthNetworkConfig {
    public static let shared = AuthNetworkConfig()
    
    public let tokenSignIn = "/auth"
    public let pinValidation = "/pin/validation"
    public let changePassword = "/password"
    public let savePin = "/pin"
    
}
