import PromiseKit
import Foundation
import ObjectMapper

class DefaultSignInViewState : DefaultBaseViewState, SignInViewState {
    
    public lazy var paymentService: PaymentService = DefaultPaymentService()
    
    func signIn(email: String, password: String) -> Promise<TokenObject> {
        return service.signIn(email: email, password: password)
    }
    
    func getHashPass(email: String, password: String) -> String {
        return self.getHashPass(value: password + email)
    }
    
    func savePreference(tokenObject: TokenObject, email: String) {
        CredentialManager.shared.saveTokenObject(tokenObject, userName: email)
        UserPreference.shared.saveForceUpdatePassword(tokenObject.forcePasswordUpdate)
        UserPreference.shared.saveForceUpdatePin(tokenObject.forcePasswordUpdate! ? true : tokenObject.forceUpdatePin)
        FilterPreference.shared.saveMinValue(0)
        FilterPreference.shared.saveMaxValue(1000000)
        self.getBaseAssetsStringJson()
            .then(execute: { [weak self] (result: String) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.fillAssetsInfo(res: result)
            })
    }
    
    private func getBaseAssetsStringJson() -> Promise<String> {
        return self.paymentService.getBaseAssetsList()
    }
    
    private func fillAssetsInfo(res: String) {
        let items = !res.isEmpty ? Mapper<SettingsMerchantsModel>().mapArray(JSONObject: res.toJSON())! : Array<SettingsMerchantsModel>()
        
        for item in items {
            if let isSelected = (item as SettingsMerchantsModel).isSelected, isSelected {
                UserPreference.shared.saveCurrentCurrency(item)
            }
        }
    }
    
}
