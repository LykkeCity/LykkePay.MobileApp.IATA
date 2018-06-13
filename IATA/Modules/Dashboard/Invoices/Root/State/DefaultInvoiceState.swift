import Foundation
import PromiseKit
import ObjectMapper

class DefaultInvoiceState: InvoiceState {
    
    private let menuItems = ["Invoice.Navigation.Filtering.Title.AllInvoices".localize(), "Invoice.Navigation.Filtering.Title.UnPaidInvoices".localize(), "Invoice.Navigation.Filtering.Title.Dispute".localize()]
    private var selectedItems = Array<InvoiceModel>()
    public lazy var service: PaymentService = DefaultPaymentService()
    private var invoiceParams = InvoiceRequest()
    
    func mapping(jsonString: String!) ->  Array<InvoiceModel> {
        return !jsonString.isEmpty ? Mapper<InvoiceModel>().mapArray(JSONObject: jsonString.toJSON())! : Array<InvoiceModel>()
    }
    
    func getInvoiceStringJson() -> Promise<String> {
        selectedStatus(index: FilterPreference.shared.getIndexOfStatus())
        invoiceParams?.billingCategories = FilterPreference.shared.getBillingChecked()!
        invoiceParams?.clientMerchantIds = FilterPreference.shared.getAirlines()!
        invoiceParams?.lessThan = FilterPreference.shared.getMaxValue()
        invoiceParams?.greaterThan = FilterPreference.shared.getMinValue()
        
        return self.service.getInVoices(invoceParams: invoiceParams!)
    }
    
    func getCountSelected() -> Int {
        return self.selectedItems.count
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
            resultAmount -= invoice.paidAmount!
        }
        return resultAmount
    }
    
    func selectedStatus(index: Int) {
        switch index {
        case 0:
            invoiceParams?.statuses = InvoiceStatuses.all.rawValue
            invoiceParams?.dispute = nil
            break
        case 1:
            invoiceParams?.statuses = InvoiceStatuses.Unpaid.rawValue
            invoiceParams?.dispute = nil
            break
        case 2:
            invoiceParams?.statuses = InvoiceStatuses.all.rawValue
            invoiceParams?.dispute = true
            break
        default:
            break
        }
        
    }
    
    func isChecked(model: InvoiceModel) -> Bool {
        return (self.selectedItems.index(where: {$0 === model}) != nil)
    }
    
    func isCanBeOpenDispute(model: InvoiceModel) -> Bool {
        return ((model.status?.rawValue.elementsEqual(InvoiceStatuses.Unpaid.rawValue))! && !model.dispute!)
    }
    
    func isCanBeClosedDispute(model: InvoiceModel) -> Bool {
        return ((model.status?.rawValue.elementsEqual(InvoiceStatuses.Unpaid.rawValue))! && model.dispute!)
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
