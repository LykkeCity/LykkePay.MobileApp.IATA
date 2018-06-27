import Foundation
import PromiseKit
import ObjectMapper

class DefaultInvoiceState: DefaultBaseState<InvoiceModel> {
    
    private var menuItems: [Menu] = [
        Menu(type: MenuEnum.All, title: R.string.localizable.invoiceNavigationFilteringTitleAllInvoices(), isActive: false),
        Menu(type: MenuEnum.Paid, title: R.string.localizable.invoiceNavigationFilteringTitlePaid(), isActive: false),
        Menu(type: MenuEnum.Unpaid, title: R.string.localizable.invoiceNavigationFilteringTitleUnPaidInvoices(), isActive: false),
        Menu(type: MenuEnum.Dispute, title: R.string.localizable.invoiceNavigationFilteringTitleDispute(), isActive: false)
    ]
    
    private var selectedItems = Array<InvoiceModel>()
    private var invoiceParams = InvoiceRequest()
   
    public lazy var service: PaymentService = DefaultPaymentService()
    public var amount = 0.0
    
    
    func mapping(jsonString: String!)  {
        if let invoices = Mapper<InvoiceModel>().mapArray(JSONObject: jsonString.toJSON()) {
            self.items = !jsonString.isEmpty ? invoices : Array<InvoiceModel>()
        }
    }
    
    func clearSelectedItems() {
        self.selectedItems = []
    }
    
    func initSelected() {
        if let menuItem = FilterPreference.shared.getIndexOfStatus(), let menu = MenuEnum(rawValue: menuItem) {
            selectedStatus(type: menu)
        }  else {
            selectedStatus(type: MenuEnum.All)
        }
    }
    
    func getInvoiceStringJson() -> Promise<String> {
        initSelected()
        self.invoiceParams?.billingCategories = FilterPreference.shared.getBillingChecked()
        self.invoiceParams?.clientMerchantIds = FilterPreference.shared.getAirlines()
        self.invoiceParams?.settlementAssets = FilterPreference.shared.getCurrency()
        self.invoiceParams?.lessThan = FilterPreference.shared.getMaxValue()
        self.invoiceParams?.greaterThan = FilterPreference.shared.getMinValue()
        
        return self.service.getInVoices(invoceParams: self.invoiceParams!)
    }
    
    func makePayment(items: [String]?, amount: String?) -> Promise<BaseMappable> {
        let model = PaymentRequest()
        model?.invoicesIds = items
        if let amountValue = amount, let amountDouble = Double(amountValue) {
            let decimal = NSDecimalNumber(value: amountDouble)
            model?.amountInBaseAsset = decimal.rounded(places: 6)
        }
        return self.service.makePayment(model: model!)
    }
    
    func getAmount() -> Promise<PaymentAmount> {
        let items = getItemsId()
        return self.service.getAmount(invoicesIds: items)
    }
    
    func getCountSelected() -> Int {
        return self.selectedItems.count
    }
    
    func getMenuItems() -> [Menu] {
        return self.menuItems
    }
    
    func selectedStatus(type: MenuEnum) {
        cleanUpActive(type: type)
        switch type {
        case .All:
            initStatus(status: InvoiceStatuses.all, dispute: nil)
            break
        case .Paid:
            initStatus(status: InvoiceStatuses.Paid, dispute: nil)
            break
        case .Unpaid:
            initStatus(status: InvoiceStatuses.Unpaid, dispute: nil)
            break
        case .Dispute:
            initStatus(status: InvoiceStatuses.all, dispute: true)
            break
        }
    }
    
    func getIndex() -> Int{
        if let menuItem = FilterPreference.shared.getIndexOfStatus(), let index = self.menuItems.index(where: {$0.type == MenuEnum(rawValue: menuItem)}) {
            return index
        }
        return 0
    }
    
    private func cleanUpActive(type: MenuEnum) {
        var items = [Menu]()
        for var item in menuItems {
            item.isActive = item.type == type
            items.append(item)
        }
        menuItems = items
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
        guard let isDispute = self.items[index].dispute else {
            return false
        }
        return isDispute
    }
    
    private func addNewSelectedModel(model: InvoiceModel) {
        self.selectedItems.append(model)
    }
    
    private func removeSelectedModel(model: InvoiceModel) {
        if let index = self.selectedItems.index(where: {$0 === model}) {
            self.selectedItems.remove(at: index)
        }
    }
    
    func newItem(isSelected: Bool, index: Int) {
        isSelected ? addNewSelectedModel(model: getItems()[index]) : removeSelectedModel(model: getItems()[index])
    }
    
    func getSelectedString() -> String {
        if self.getCountSelected() == 1 {
            return R.string.localizable.invoiceScreenItemsOneSelected()
        } else {
            return R.string.localizable.invoiceScreenItemsCountSelected(String(self.getCountSelected()))
        }
    }
    
    func getItemsId() -> [String] {
        var items = [String]()
        for item in selectedItems {
            if let id = item.id {
                items.append(id)
            }
        }
        return items
    }

    func cancelDisputInvoice(model: CancelDisputInvoiceRequest) -> Promise<Void> {
        return self.service.cancelDisputInvoice(model: model)
    }
    
}
