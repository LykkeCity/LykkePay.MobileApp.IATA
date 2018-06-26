import Foundation
import PromiseKit
import ObjectMapper

class DefaultExchangeState: DefaultBaseState<ExchangeViewModel> {

    public lazy var service: PaymentService = DefaultPaymentService()
    public lazy var walletsState = DefaultWalletsState()
    public var currentCurrency = UserPreference.shared.getCurrentCurrency()
    
    public var usd: WalletsViewModel?
    public var euro: WalletsViewModel?
    
    func makeExchange(model: ExchangeRequest) -> Promise<BaseMappable> {
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
        if let items = self.walletsState?.getItems() {
            for wallet in items {
                if let id = currentCurrency?.id, let assetId = wallet.assetId,  !assetId.elementsEqual(id) && (assetId.isUsd() || assetId.isEuro()) {
                    currentCurrency?.id = wallet.assetId
                    currentCurrency?.symbol = assetId.isUsd() ? "$" : "€"
                }
            }
        }
        
        for  item in self.getItems() {
            if let isBase = item.isBase {
                item.isBase = !isBase
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
        
        if let baseId = currentCurrency?.id, let current =  self.usd?.assetId {
            items.append(ExchangeViewModel(isUsd: true, state: self, isBase: current.elementsEqual(baseId)))
            items.append(ExchangeViewModel(isUsd: false, state: self, isBase: !current.elementsEqual(baseId)))
        }
    }


}
