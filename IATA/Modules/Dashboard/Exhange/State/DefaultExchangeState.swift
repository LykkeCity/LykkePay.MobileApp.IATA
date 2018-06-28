import Foundation
import PromiseKit
import ObjectMapper

class DefaultExchangeState: DefaultBaseState<ExchangeViewModel> {

    public lazy var service: PaymentService = DefaultPaymentService()
    public lazy var walletsState = DefaultWalletsState()
    public var currentCurrency = UserPreference.shared.getCurrentCurrency()
    
    public var usd: WalletsViewModel?
    public var euro: WalletsViewModel?
    public var exchangeModel: ExchangeModel = ExchangeModel()
    public var maxValue: Double? = 0.0
    
    func loadExchangeData(sourceAmount: String?) -> Promise<ExchangeModel> {
        let model = PreExchangeRequest()
        model.destAssetId = self.exchangeModel.destAssetId
        model.sourceAmount = 0
        model.sourceAssetId = self.exchangeModel.sourceAssetId
        return self.service.loadExchangeInfo(model: model)
    }
    
    func makeExchange(sourceAmount: String?) -> Promise<ExchangeModel> {
        let model = ExchangeRequest()
        model.destAssetId = self.exchangeModel.destAssetId
        if let valueString = sourceAmount, let amount = Double(valueString) {
            let decimal = NSDecimalNumber(value: amount)
            model.sourceAmount = decimal.rounded(places: 6)
            self.exchangeModel.sourceAmount = 0
        }
        
        if let value = self.exchangeModel.rate {
            let decimal = NSDecimalNumber(value: value)
            model.expectedRate = decimal.rounded(places: 6)
        }
        
        model.sourceAssetId = self.exchangeModel.sourceAssetId
        return self.service.makeExchange(model: model)
    }
    
    func loadStartData() -> Promise<String>? {
        if let id = currentCurrency?.id {
            if let stateValue = self.walletsState?.getWalletsStringJson(id: id) {
                return stateValue
            }
        }
        return nil
    }
    
    func getBaseAsset() -> ExchangeViewModel? {
        for item in items {
            if let isBase = item.isBase, isBase {
                return item
            }
        }
        return nil
    }
    
    func changeBaseAsset() {
        for  item in self.getItems() {
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

    func getTotalBalance() -> String? {
        if  let item = getBaseAsset(), let sum = item.sum, let currency = item.currency {
            return Formatter.formattedWithSeparator(valueDouble: sum) + " " + currency
        }
        return nil
    }
    
    func mapping(jsonString: String!) {
        self.walletsState?.mapping(jsonString: jsonString)
        //for only first version
        if let items = self.walletsState?.getItems() {
            for wallet in items {
                if let assetId = wallet.assetId, assetId.isUsd() {
                    self.usd = wallet
                } else if let assetId = wallet.assetId, assetId.isEuro() {
                    self.euro = wallet
                }
            }
        }
        
        self.reinit()
    }
    
    private func reinit() {
        items = [ExchangeViewModel]()
        if let baseId = currentCurrency?.id, let usdAssetId = self.usd?.assetId, let euroAssetId = self.euro?.assetId{
            items.append(ExchangeViewModel(isUsd: true, state: self, isBase: usdAssetId.elementsEqual(baseId), assetId: usdAssetId))
            items.append(ExchangeViewModel(isUsd: false, state: self, isBase: !usdAssetId.elementsEqual(baseId), assetId: euroAssetId))
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
