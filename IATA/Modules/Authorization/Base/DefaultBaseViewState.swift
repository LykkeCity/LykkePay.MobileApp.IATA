import Foundation

class DefaultBaseViewState : BaseViewState {
    public lazy var service: AuthenticationService = DefaultAuthenticationService()
    
    func getHashPass(value: String) -> String {
        return (value.sha1().data(using: .bytesHexLiteral)?.base64EncodedString())!
    }
    
    func getError(_ name:String, values: [String]) -> NSError {
        var resMessage = ""
        for message in values {
            resMessage.append(message)
            resMessage.append("\n")
        }
        let userInfo = [NSLocalizedDescriptionKey: resMessage]
        return NSError(domain: name, code: 123, userInfo: userInfo)
    }
}
