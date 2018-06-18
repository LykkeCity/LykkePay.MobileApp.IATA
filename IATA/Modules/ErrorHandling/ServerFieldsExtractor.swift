import UIKit

class ServerFieldsErrorExtractor: NSObject {
    
    
    internal func extract(model: ModelErrors) -> IATAOpError? {
        var dic1 = getEmailMessageError(model.email)
        let dic2 = getPasswordMessageError(model.password)
        let dic3 = getCurrentPasswordMessageError(model.currentPassword)
        dic1.merge(dict: dic2)
        dic1.merge(dict: dic3)
        if (!dic1.isEmpty) {
            return IATAOpError.validation(map: dic1)
        } else {
            return nil
        }
    }
    
    private func getEmailMessageError(_ dict: [String]?) ->  Dictionary<String, [String]> {
        return getListOfMessageError(key: PropertyValidationKey.email.rawValue, dict: dict)
    }
    
    private func getPasswordMessageError(_ dict: [String]?) ->  Dictionary<String, [String]> {
        return getListOfMessageError(key: PropertyValidationKey.password.rawValue, dict: dict)
    }
    
    private func getCurrentPasswordMessageError(_ dict: [String]?) ->  Dictionary<String, [String]> {
        return getListOfMessageError(key: PropertyValidationKey.currentPasssword.rawValue, dict: dict)
    }
    
    private func getListOfMessageError(key: String, dict: [String]?) ->  Dictionary<String, [String]> {
        var result = Dictionary<String, [String]>()
        result[key] = dict
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
