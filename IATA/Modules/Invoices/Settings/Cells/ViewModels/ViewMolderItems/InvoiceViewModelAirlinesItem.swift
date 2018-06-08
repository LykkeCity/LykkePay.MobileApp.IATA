class InvoiceViewModelAirlinesItem: InvoiceViewModelItem {
    var type: InvoiceViewModelItemType {
        return .airlines
    }
    
    var sectionTitle: String {
        return "Invoice.Settings.Airlines.Title".localize()
    }
    
    var rowCount: Int {
        return airlines.count
    }
    
    var airlines: [AirlinesInvoiceModel]
    
    init(airlines: [AirlinesInvoiceModel]) {
        self.airlines = airlines
    }
}
