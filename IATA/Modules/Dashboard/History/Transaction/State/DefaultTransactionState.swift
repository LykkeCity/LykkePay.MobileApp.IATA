import Foundation
import PromiseKit
import ObjectMapper

class DefaultTransactionState: DefaultBaseState<PropertyKeyTransactionModel> {
    
    public lazy var service: PaymentService = DefaultPaymentService()
    
    
    func getHistoryDetails(id: String) -> Promise<HistoryTransactionModel> {
        return self.service.getHistoryDetails(id: id)
    }
    
    func initItems(item: HistoryTransactionModel) {
        self.items = item.valueFor()
    }
    
}
