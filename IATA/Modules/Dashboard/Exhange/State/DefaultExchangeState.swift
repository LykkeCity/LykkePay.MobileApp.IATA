import Foundation
import PromiseKit
import ObjectMapper

class DefaultExchangeState: DefaultBaseState<ExchangeModel> {

    public lazy var service: PaymentService = DefaultPaymentService()

    public lazy var walletsState = DefaultWalletsState()

    func makeExchange(model: ExchangeRequest) -> Promise<BaseMappable> {
        return self.service.makeExchange(model: model)
    }



}
