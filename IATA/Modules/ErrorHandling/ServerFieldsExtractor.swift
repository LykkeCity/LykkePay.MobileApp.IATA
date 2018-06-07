import UIKit

class ServerFieldsErrorExtractor: NSObject {
    
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
        var dic1 = getEmailMessageError(jsonDict)
        let dic2 = getPasswordMessageError(jsonDict)
        let dic3 = getCurrentPasswordMessageError(jsonDict)
        dic1.merge(dict: dic2)
        dic1.merge(dict: dic3)
        if (!dic1.isEmpty) {
            return IATAOpError.validation(map: dic1)
        } else {
            return nil
        }
    }
    
    private func getEmailMessageError(_ jsonDict: [String: Any]) ->  Dictionary<String, [String]> {
        return getListOfMessageError(key: PropertyValidationKey.email.rawValue, jsonDict: jsonDict)
    }
    
    private func getPasswordMessageError(_ jsonDict: [String: Any]) ->  Dictionary<String, [String]> {
        return getListOfMessageError(key: PropertyValidationKey.password.rawValue, jsonDict: jsonDict)
    }
    
    private func getCurrentPasswordMessageError(_ jsonDict: [String: Any]) ->  Dictionary<String, [String]> {
        return getListOfMessageError(key: PropertyValidationKey.currentPasssword.rawValue, jsonDict: jsonDict)
    }
    
    private func getListOfMessageError(key: String, jsonDict: [String: Any]) ->  Dictionary<String, [String]> {
        guard let list = jsonDict[key] as? [String] else {
            return Dictionary<String, [String]>()
        }
        
        var preResult = [String]()
        for message in list {
            preResult.append(message)
        }
        
        var result = Dictionary<String, [String]>()
        result[key] = preResult
        return result
    }
    
    private func convertToDictionary(text: String) -> [String: Any]? {
        guard let data = text.data(using: .utf8) else {
            return nil
        }
        let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
        return jsonObject as? [String: Any]
    }
}
