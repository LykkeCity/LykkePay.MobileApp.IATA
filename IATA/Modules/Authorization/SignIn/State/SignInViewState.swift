import PromiseKit

protocol SignInViewState {
    
    func getHashPass(email: String, password: String) -> String
    func signIn(email: String, password: String) -> Promise<TokenObject>
    func getError(_ name:String, values: [String]) -> NSError 
    
}
