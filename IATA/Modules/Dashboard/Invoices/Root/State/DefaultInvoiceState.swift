import Foundation
import PromiseKit
import ObjectMapper

class DefaultInvoiceState: DefaultBaseState<InvoiceModel> {
    
    private let menuItems = [R.string.localizable.invoiceNavigationFilteringTitleAllInvoices(), R.string.localizable.invoiceNavigationFilteringTitleUnPaidInvoices(), R.string.localizable.invoiceNavigationFilteringTitleDispute()]
    private var selectedItems = Array<InvoiceModel>()
    private var invoiceParams = InvoiceRequest()
    public lazy var service: PaymentService = DefaultPaymentService()
    public var amount = 0
    
    
    func mapping(jsonString: String!)  {
        self.items = !jsonString.isEmpty ? Mapper<InvoiceModel>().mapArray(JSONObject: jsonString.toJSON())! : Array<InvoiceModel>()
    }
    
    func clearSelectedItems() {
        self.selectedItems = []
    }
    
    func getInvoiceStringJson() -> Promise<String> {
        selectedStatus(index: FilterPreference.shared.getIndexOfStatus())
        self.invoiceParams?.billingCategories = FilterPreference.shared.getBillingChecked()
        self.invoiceParams?.clientMerchantIds = FilterPreference.shared.getAirlines()
        self.invoiceParams?.settlementAssets = FilterPreference.shared.getCurrency()
        self.invoiceParams?.lessThan = FilterPreference.shared.getMaxValue()
        self.invoiceParams?.greaterThan = FilterPreference.shared.getMinValue()
        
        return self.service.getInVoices(invoceParams: self.invoiceParams!)
    }
    
    func makePayment() -> Promise<Void> {
        let model = PaymentRequest()
        model?.invoicesIds = getItemsId()
        model?.amountInBaseAsset = amount
        return self.service.makePayment(model: model!)
    }
    
    func getAmount() -> Promise<PaymentAmount> {
        let items = getItemsId()
        return self.service.getAmount(invoicesIds: items)
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
        return R.string.localizable.invoiceScreenItemsCountSelected(String(self.getCountSelected()))
    }
    
    private func getItemsId() -> [String] {
        var items = [String]()
        for item in selectedItems {
            if let id = item.id {
                items.append(id)
            }
        }
        return items
    }
    
}
