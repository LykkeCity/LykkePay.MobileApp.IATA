import ObjectMapper

class NetworkUtil: NSObject {
    
    public static func makeIdTransfrom() -> TransformOf<String, Int> {
        return TransformOf<String, Int>(fromJSON: { String($0!) },
                                        toJSON: { $0.map { Int($0)! } })
    }
    
    public static func makeFullUrl(baseUrl: String, path: String) -> String {
        precondition(!baseUrl.hasSuffix("/"))
        if path.hasPrefix("/") {
            return baseUrl + path
        }
        return baseUrl + "/" + path
    }
    
}
