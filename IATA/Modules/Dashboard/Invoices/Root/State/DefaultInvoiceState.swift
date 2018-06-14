import Foundation
import PromiseKit
import ObjectMapper

class DefaultInvoiceState: DefaultBaseState<InvoiceModel> {
    
    private let menuItems = ["Invoice.Navigation.Filtering.Title.AllInvoices".localize(), "Invoice.Navigation.Filtering.Title.UnPaidInvoices".localize(), "Invoice.Navigation.Filtering.Title.Dispute".localize()]
    private var selectedItems = Array<InvoiceModel>()
    public lazy var service: PaymentService = DefaultPaymentService()
    private var invoiceParams = InvoiceRequest()
    
    func mapping(jsonString: String!)  {
        self.items = !jsonString.isEmpty ? Mapper<InvoiceModel>().mapArray(JSONObject: jsonString.toJSON())! : Array<InvoiceModel>()
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
            initStatus(status: InvoiceStatuses.all, dispute: nil)
            break
        case 1:
            initStatus(status: InvoiceStatuses.Unpaid, dispute: nil)
            break
        case 2:
            initStatus(status: InvoiceStatuses.all, dispute: true)
            break
        default:
            break
        }
        
    }
    
    private func initStatus(status: InvoiceStatuses, dispute: Bool?) {
        invoiceParams?.statuses =  status.rawValue
        invoiceParams?.dispute = dispute
    }
    
    func isChecked(model: InvoiceModel) -> Bool {
        return (self.selectedItems.index(where: {$0 === model}) != nil)
    }
    
    func isCanBeOpenDispute(index: Int) -> Bool {
        guard let status = self.items[index].status?.rawValue else {
            return false
        }
        guard let isDispute = self.items[index].dispute else {
            return false
        }
        return (status.elementsEqual(InvoiceStatuses.Unpaid.rawValue) && !isDispute)
    }
    
    func isCanBeClosedDispute(index: Int) -> Bool {
        guard let status = self.items[index].status?.rawValue else {
            return false
        }
        guard let isDispute = self.items[index].dispute else {
            return false
        }
        return (status.elementsEqual(InvoiceStatuses.Unpaid.rawValue) && isDispute)
    }
    
    private func addNewSelectedModel(model: InvoiceModel) {
        self.selectedItems.append(model)
    }
    
    private func removeSelectedModel(model: InvoiceModel) {
        if let index = self.selectedItems.index(where: {$0 === model}) {
            self.selectedItems.remove(at: index)
        }
    }
    
    func getSumString(isSelected: Bool, index: Int) -> String {
        return String(self.recalculateAmount(isSelected: isSelected, model: self.items[index]))
    }
    
    func getSelectedString() -> String {
        return String(format: "Invoice.Screen.Items.CountSelected".localize(), String(self.getCountSelected()))
    }
    
}
