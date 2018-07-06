import Foundation
import PromiseKit
import ObjectMapper

class DefaultSettingsState: DefaultBaseState<SettingsMerchantsModel> {

    public lazy var service: PaymentService = DefaultPaymentService()

    func getSettingsStringJson() -> Promise<SettingsModel> {
        return self.service.getSettings()
    }

    func getBaseAssetsStringJson() -> Promise<String> {
        return self.service.getBaseAssetsList()
    }

    func setBaseAsset(baseAsset: String) -> Promise<Void> {
        return self.service.postBaseAssets(baseAsset: baseAsset)
    }

    func mappingSettings(settingsModel: SettingsModel) -> SettingsViewModel {
        let settingsViewModel = prepareSettingsViewModels(from: settingsModel)
        return settingsViewModel
    }

    func mappingBaseAssets(jsonString: String!) {
        self.items = !jsonString.isEmpty ? Mapper<SettingsMerchantsModel>().mapArray(JSONObject: jsonString.toJSON())! : Array<SettingsMerchantsModel>()
    }

    func prepareSettingsViewModels(from settingsModel: SettingsModel) -> SettingsViewModel {
        let settingForPresent = SettingsViewModel()
        settingForPresent.merchantName = settingsModel.merchantName
        settingForPresent.merchantLogoUrl = settingsModel.merchantLogoUrl
        settingForPresent.firstName = settingsModel.firstName
        settingForPresent.lastName = settingsModel.lastName
        settingForPresent.email = settingsModel.email
        return settingForPresent
    }

}
