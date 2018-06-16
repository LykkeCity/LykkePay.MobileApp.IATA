import Foundation

class DefaultBaseViewState : BaseViewState {
    public lazy var service: AuthenticationService = DefaultAuthenticationService()
    
    func getHashPass(value: String) -> String {
        return (value.sha1().data(using: .bytesHexLiteral)?.base64EncodedString())!
    }
    
    func getError(_ name:String, values: [String]) -> String {
        var resMessage = ""
        for message in values {
            resMessage.append(message)
            resMessage.append("\n")
        }
        return resMessage
    }
    
    func getError(_ message: String) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: message]
        return NSError(domain: message, code: 123, userInfo: userInfo)
    }
}
