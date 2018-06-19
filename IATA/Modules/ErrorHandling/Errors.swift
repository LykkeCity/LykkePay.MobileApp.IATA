import ObjectMapper

enum IATAOpError: Error {
    case serverError(message: String)
    case validation(map: Dictionary<String, [String]>)
}

extension IATAOpError: LocalizedError {
    var localizedDescription: String {
        switch self {
        case let .serverError(message):
            return message
        case .validation(_):
            return ""
        }
    }
    
    var validationError: Dictionary<String, [String]> {
        switch self {
        case let .validation(map):
            return map
        case .serverError(_):
            let result = Dictionary<String, [String]>()
            return result
        }
    }
}
