import PromiseKit

protocol SignInViewState: BaseViewState{
    
    func getHashPass(email: String, password: String) -> String
    func signIn(email: String, password: String) -> Promise<TokenObject>
    func getError(_ name:String, values: [String]) -> NSError
    func savePreference(tokenObject: TokenObject, email: String) 
    
}
