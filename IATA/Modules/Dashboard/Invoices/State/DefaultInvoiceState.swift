import Foundation
import PromiseKit
import ObjectMapper

class DefaultInvoiceState: InvoiceState {
    
    private let menuItems = ["Invoice.Navigation.Filtering.Title.AllInvoices".localize(), "Invoice.Navigation.Filtering.Title.UnPaidInvoices".localize(), "Invoice.Navigation.Filtering.Title.Dispute".localize()]
    private var selectedItems = Array<InvoiceModel>()
    public lazy var service: PaymentService = DefaultPaymentService()
    
    func mapping(jsonString: String!) ->  Array<InvoiceModel> {
        return Mapper<InvoiceModel>().mapArray(JSONObject: jsonString.toJSON())!
    }
    
    func getInvoiceStringJson() -> Promise<String> {
        return self.service.getInVoices()
    }
    
    func getMenuItems() -> [String] {
        return self.menuItems
    }
    
    func recalculateAmount(isSelected: Bool, model: InvoiceModel) -> Double {
        isSelected ? self.addNewSelectedModel(model: model) : self.removeSelectedModel(model: model)
        return resultAmount()
    }
    

    func resultAmount() -> Double {
        var resultAmount = 0.0
        for invoice in self.selectedItems {
            resultAmount += invoice.amount!
        }
        return resultAmount
    }
    
    private func addNewSelectedModel(model: InvoiceModel) {
        self.selectedItems.append(model)
    }
    
    private func removeSelectedModel(model: InvoiceModel) {
        if let index = self.selectedItems.index(where: {$0 === model}) {
            self.selectedItems.remove(at: index)
        }
    }
    
}
