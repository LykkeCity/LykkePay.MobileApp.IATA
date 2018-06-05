import UIKit

class ServerErrorExtractor: NSObject {
    private let serverValidationErrorExtractor = ServerFieldsErrorExtractor()
    
    private enum PropertyKey: String {
        case errorMessage
        case modelErrors
        case message = "Message"
    }
    
    internal func extract(from responseBody: String) -> IATAOpError? {
        guard let json = convertToDictionary(text: responseBody) else {
            return nil
        }
        return extract(from: json)
    }
    
    internal func extract(from responseBody: Any) -> IATAOpError? {
        guard let jsonDict = responseBody as? [String: Any] else {
            return nil
        }
        
        return getMessageError(jsonDict) ?? getServerValidationError(jsonDict) ??
            getTechnicalMessageError(jsonDict)
    }
    
    private func getServerValidationError(_ jsonDict: [String: Any]) -> IATAOpError? {
        return serverValidationErrorExtractor.extract(from: jsonDict)
    }
    
    private func getMessageError(_ jsonDict: [String: Any]) -> IATAOpError? {
        guard let message = jsonDict[PropertyKey.message.rawValue] as? String else {
            return nil
        }
        
        return IATAOpError.serverError(message: message)
    }
    
    private func getTechnicalMessageError(_ jsonDict: [String: Any]) -> IATAOpError? {
        guard let message = jsonDict[PropertyKey.errorMessage.rawValue] as? String else {
            return nil
        }
        
        return IATAOpError.serverError(message: message)
    }
    
    
    private func convertToDictionary(text: String) -> [String: Any]? {
        guard let data = text.data(using: .utf8) else {
            return nil
        }
        let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
        return jsonObject as? [String: Any]
    }
}
