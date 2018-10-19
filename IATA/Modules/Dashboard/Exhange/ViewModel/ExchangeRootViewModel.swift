import Foundation

class ExchangeRootViewModel {
    
    public var items: [ExchangeViewModel] = [ExchangeViewModel]()
    public var usd: WalletsViewModel?
    public var euro: WalletsViewModel?
    public var currentCurrency = UserPreference.shared.getCurrentCurrency()
    public var exchangeModel: ExchangeModel = ExchangeModel()
    public var maxValue: Double? = 0.0
    
    func getPreExchangeRequest(sourceAmount: Double?) -> PreExchangeRequest{
        let model = PreExchangeRequest()
        model.destAssetId = self.exchangeModel.destAssetId
        model.sourceAmount = sourceAmount
        model.sourceAssetId = self.exchangeModel.sourceAssetId
        return model
    }
    
    func getExchangeRequest(sourceAmount: ExchangeModel, amount: String?) -> ExchangeRequest{
        self.exchangeModel = sourceAmount
        let model = ExchangeRequest()
        model.destAssetId = self.exchangeModel.destAssetId
        if let valueString = amount, let amount = Double(valueString) {
            let decimal = NSDecimalNumber(value: amount)
            model.sourceAmount = decimal.rounded(places: 6)
            self.exchangeModel.sourceAmount = 0
        }
        
        if let value = self.exchangeModel.rate {
            let decimal = NSDecimalNumber(value: value)
            model.expectedRate = decimal.rounded(places: 6)
        }
        
        model.sourceAssetId = self.exchangeModel.sourceAssetId
        return model
    }
    
    func changeBaseAsset() {
        for  item in items {
            if let isBase = item.isBase {
                item.isBase = !isBase
                if !isBase {
                    self.maxValue = item.sum
                    self.exchangeModel.destAssetId = currentCurrency?.id
                    currentCurrency?.symbol = item.currency
                    currentCurrency?.id = item.assetId
                    self.exchangeModel.sourceAssetId = item.assetId
                }
            }
        }
        self.reinit()
    }
    
    func getBaseAsset() -> ExchangeViewModel? {
        for item in items {
            if let isBase = item.isBase, isBase {
                return item
            }
        }
        return nil
    }
    
    func initWallets(walletState: DefaultWalletsState) {
        //for only first version
        for wallet in walletState.getItems() {
            if let assetId = wallet.assetId, assetId.isUsd() {
                self.usd = wallet
            } else if let assetId = wallet.assetId, assetId.isEuro() {
                self.euro = wallet
            }
        }
    }
    
    func reinit() {
        items = [ExchangeViewModel]()
        if let baseId = currentCurrency?.id, let usdAssetId = self.usd?.assetId, let euroAssetId = self.euro?.assetId{
            items.append(ExchangeViewModel(isUsd: true,
                                           isBase: usdAssetId.elementsEqual(baseId),
                                           assetId: usdAssetId,
                                           totalUsd: usd?.totalBalance,
                                           totalEuro: euro?.totalBalance))
            items.append(ExchangeViewModel(isUsd: false,
                                           isBase: !usdAssetId.elementsEqual(baseId),
                                           assetId: euroAssetId,
                                           totalUsd: usd?.totalBalance,
                                           totalEuro: euro?.totalBalance))
            if usdAssetId.elementsEqual(baseId) {
                self.maxValue = usd?.totalBalance
                exchangeModel.destAssetId = euro?.assetId
                exchangeModel.sourceAssetId = usd?.assetId
            } else {
                self.maxValue = euro?.totalBalance
                exchangeModel.destAssetId = usd?.assetId
                exchangeModel.sourceAssetId = euro?.assetId
            }
        }
    }
}
