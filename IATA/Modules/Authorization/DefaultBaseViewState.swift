import Foundation

class DefaultBaseViewState : BaseViewState {
    public lazy var service: AuthenticationService = DefaultAuthenticationService()
    
    func getHashPass(value: String) -> String {
        return (value.sha1().data(using: .bytesHexLiteral)?.base64EncodedString())!
    }
}
