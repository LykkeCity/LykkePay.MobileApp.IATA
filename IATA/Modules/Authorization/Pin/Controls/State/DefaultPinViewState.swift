import PromiseKit
import Foundation
import ObjectMapper

class DefaultPinViewState: DefaultBaseViewState, PinViewState {
    
   public lazy var paymentService: PaymentService = DefaultPaymentService()
    
    func validatePin(pin: String) -> Promise<PinValidationResponse> {
        self.initUser()
        if let userName = CredentialManager.shared.getUserName() {
            let value =  pin + userName
            return self.service.pinValidation(pinCode: getHashPass(value: value))
        }
        return self.service.pinValidation(pinCode: "")
    }
    
    func initBaseAssert() {
        self.getBaseAssetsStringJson()
            .then(execute: { [weak self] (result: String) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.fillAssetsInfo(res: result)
            })
    }
    
    
    func initUser() {
        self.getUserInfo()
            .then(execute: { [weak self] (result: SettingsModel) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.saveUserInfo(res: result)
            })
    }
    
    
    func savePin(pin: String) -> Promise<Void> {
        let value =  pin + CredentialManager.shared.getUserName()!
        return self.service.savePin(pinCode: getHashPass(value: value))
    }
    
    private func getUserInfo() -> Promise<SettingsModel> {
        return self.paymentService.getSettings()
    }
    
    private func saveUserInfo(res: SettingsModel) {
        if let isInternalSupervisor = res.isInternalSupervisor {
            UserPreference.shared.saveSuperviser(isInternalSuperviser: isInternalSupervisor)
        }
    }
    
    private func getBaseAssetsStringJson() -> Promise<String> {
        return self.paymentService.getBaseAssetsList()
    }
    
    
    private func fillAssetsInfo(res: String) {
       
        let items = !res.isEmpty ? Mapper<SettingsMerchantsModel>().mapArray(JSONObject: res.toJSON()) : Array<SettingsMerchantsModel>()
        
        if let listItems = items {
            for item in listItems {
                if let isSelected = (item as SettingsMerchantsModel).isSelected, isSelected {
                    UserPreference.shared.saveCurrentCurrency(item)
                }
            }
        }
    }
}
