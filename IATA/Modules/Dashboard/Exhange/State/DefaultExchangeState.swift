import Foundation
import PromiseKit
import ObjectMapper

class DefaultExchangeState {

    public lazy var service: PaymentService = DefaultPaymentService()
    public lazy var walletsState = DefaultWalletsState()
    public lazy var viewModel: ExchangeRootViewModel =  ExchangeRootViewModel()
    
    func loadExchangeData(sourceAmount: String?) -> Promise<ExchangeModel> {
        let model = viewModel.getPreExchangeRequest()
        return self.service.loadExchangeInfo(model: model)
    }
    
    func makeExchange(sourceAmount: String?) -> Promise<ExchangeModel> {
        let model = viewModel.getExchangeRequest(sourceAmount: sourceAmount)
        return self.service.makeExchange(model: model)
    }
    
    func loadStartData() -> Promise<String>? {
        if let id = self.viewModel.currentCurrency?.id {
            if let stateValue = self.walletsState?.getWalletsStringJson(id: id) {
                return stateValue
            }
        }
        return nil
    }
    
    func getBaseAsset() -> ExchangeViewModel? {
        return self.viewModel.getBaseAsset()
    }
    
    func changeBaseAsset() {
        self.viewModel.changeBaseAsset()
    }

    func getTotalBalance() -> String? {
        if  let item = getBaseAsset(), let sum = item.sum, let currency = item.currency {
            return Formatter.formattedWithSeparator(valueDouble: sum) + " " + currency
        }
        return nil
    }
    
    func mapping(jsonString: String!) {
        self.walletsState?.mapping(jsonString: jsonString)
        
        if let state = walletsState {
            self.viewModel.initWallets(walletState: state)
        }
        self.viewModel.reinit()
    }
    
}
