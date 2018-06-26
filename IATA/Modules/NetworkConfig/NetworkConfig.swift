import Foundation

class NetworkConfig {
    public static let shared = NetworkConfig()
    
    #if DEBUG
    public let baseServerURL = "https://pay-api-dev.lykkex.net/api/v1/mobile"
    public let certificateFileName = "lykkexne"
    #else
    public let baseServerURL = "https://pay-api-dev.lykkex.net/api/v1/mobile"
    public let certificateFileName = "lykkexne"
    #endif


}
