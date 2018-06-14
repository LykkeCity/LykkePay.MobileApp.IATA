import Foundation

protocol SettingsState {
    
    func setUpActiveCurrency()
    func getCurrencies() -> [InvoiceSettingAirlinesModel]
}
