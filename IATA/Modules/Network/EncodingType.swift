import Alamofire

internal enum EncodingType: Int {
    
    case url
    case json
    
    internal var parameters: ParameterEncoding {
        switch self {
        case .url:
            return URLEncoding.default
        case .json:
            return JSONEncoding.default
        }
    }
}
