import Foundation
import PromiseKit
import ObjectMapper

class DefaultHistoryState: DefaultBaseState<HistoryModel> {
    
    public lazy var service: PaymentService = DefaultPaymentService()
    
    
    func getHistory() -> Promise<String> {
        return self.service.getHistory()
    }
    
    func mapping(jsonString: String!)  {
        self.items = !jsonString.isEmpty ? Mapper<HistoryModel>().mapArray(JSONObject: jsonString.toJSON())! : Array<HistoryModel>()
    }
    
    
    
}
