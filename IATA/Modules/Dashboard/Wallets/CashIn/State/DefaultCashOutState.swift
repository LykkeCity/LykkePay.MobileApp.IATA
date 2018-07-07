
import Foundation
import PromiseKit
import ObjectMapper

class DefaultCashOutState: DefaultBaseState<CashOutViewModel> {
    
    public lazy var service: PaymentService = DefaultPaymentService()
    var viewModel = CashOutViewModel()
    
    func reinitModel(index: Int) {
        if let itemsList = self.viewModel.items {
            for item in itemsList {
                item.isSelected = false
            }
            itemsList[index].isSelected = true
        }
        self.initDesiredAssertId()
    }
    
    func getDictionary() -> Promise<String> {
        return service.getDictionaryForPayments()
    }
    
    func cashOut(amount: Double?) -> Promise<BaseMappable> {
        let model = CashOutRequest()
       
        if let amountDouble = amount {
            let decimal = NSDecimalNumber(value: amountDouble)
            model.amount =  decimal.rounded(places: 6)
        }
        
        model.assetId = self.viewModel.assertId
        model.desiredCashoutAsset = self.viewModel.desiredAssertId
        return service.cashOut(model: model)
    }
    
    func mapping(jsonString: String) {
        let items = !jsonString.isEmpty ? Mapper<DictionaryAssertId>().mapArray(JSONObject: jsonString.toJSON()) : Array<DictionaryAssertId>()
        if let listItems = items {
            self.viewModel.items = listItems
        } else {
            self.viewModel.items = [DictionaryAssertId]()
        }
        self.initDesiredAssertId()
    }
    
    private func initDesiredAssertId() {
        if let listItems = viewModel.items {
            for item in listItems {
                if let isSelected = item.isSelected, isSelected {
                    self.viewModel.desiredAssertId = item.name
                }
            }
        }
    }
}
