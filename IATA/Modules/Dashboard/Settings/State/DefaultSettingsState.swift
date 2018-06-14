import Foundation

class DefaultSettingsState: SettingsState {
    
    private var currencies: [InvoiceSettingAirlinesModel] = []
    
    internal required init() {
        let model1 = InvoiceSettingAirlinesModel()
        model1?.logo = "ic_usFlagSmallIcn"
        model1?.name = "USD"
        
        let model2 = InvoiceSettingAirlinesModel()
        model2?.logo = "ic_eurFlagSmallIcn"
        model2?.name = "EURO"
        guard let currencies = [model1, model2] as? [InvoiceSettingAirlinesModel] else {
            return
        }
        
        self.currencies = currencies
        self.setUpActiveCurrency()
    }
    
    func setUpActiveCurrency() {
        guard let activeCurrency = UserPreference.shared.getCurrentCurrency(),
            let index = (self.currencies.index(where: {$0 === activeCurrency}))  else {
                self.currencies.first?.checked = true
                UserPreference.shared.saveCurrentCurrency(self.currencies[0])
                return
        }
        self.currencies[index].checked = true
    }
    
    func getCurrencies() -> [InvoiceSettingAirlinesModel] {
        return currencies
    }
}
