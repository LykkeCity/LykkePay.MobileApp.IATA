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
    
    func makeExchange(sourceAmount: String?) -> Promise<ExchangeModel> {
        let model = ExchangeRequest()
        model.destAssetId = self.exchangeModel.destAssetId
        if let valueString = sourceAmount {
            model.sourceAmount = Double(valueString)
            self.exchangeModel.sourceAmount = 0
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
                    currentCurrency?.symbol = item.currency
                    currentCurrency?.id = item.assetId
                }
            }
        }
    }

    func getTotalBalance() -> String? {
        if  let item = getBaseAsset(), let sum = item.sum, let currency = item.currency {
            return String(sum) + " " + currency
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
        
        if let baseId = currentCurrency?.id, let usdAssetId = self.usd?.assetId, let euroAssetId = self.euro?.assetId{
            items.append(ExchangeViewModel(isUsd: true, state: self, isBase: usdAssetId.elementsEqual(baseId), assetId: usdAssetId))
            items.append(ExchangeViewModel(isUsd: false, state: self, isBase: !usdAssetId.elementsEqual(baseId), assetId: euroAssetId))
            if usdAssetId.elementsEqual(baseId) {
                self.maxValue = usd?.totalBalance
                exchangeModel.destAssetId = euro?.assetId
                exchangeModel.sourceAssetId = baseId
                exchangeModel.symbolSource = "$"
                exchangeModel.symbolDest = "€"
            } else {
                self.maxValue = usd?.totalBalance
                exchangeModel.symbolDest = "$"
                exchangeModel.symbolSource = "€"
                exchangeModel.destAssetId = baseId
                exchangeModel.sourceAssetId = euro?.assetId
            }
        }
    }


}
