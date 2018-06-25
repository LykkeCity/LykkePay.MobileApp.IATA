import ObjectMapper

class InvoiceModel: Mappable {
    
    private enum PropertyKey: String {
        case status
        case merchantName
        case id
        case number
        case clientName
        case clientEmail
        case amount
        case dueDate
        case settlementAssetId
        case paidAmount
        case paymentAssetId
        case paymentRequestId
        case merchantId
        case employeeId
        case note
        case createdDate
        case billingCategory
        case dispute
        case settlementMonthPeriod
        case iataInvoiceDate
        case logo
        case settlementPeriod
        case symbol
        case logoUrl
       
    }
    
    internal var merchantName: String?
    internal var status: InvoiceStatuses?
    internal var id: String?
    internal var number: String?
    internal var clientName: String?
    internal var clientEmail: String?
    internal var amount: Double?
    internal var dueDate: String?
    internal var settlementAssetId: String?
    internal var paidAmount: Double?
    internal var paymentAssetId: String?
    internal var paymentRequestId: String?
    internal var merchantId: String?
    internal var employeeId: String?
    internal var note: String?
    internal var createdDate: String?
    internal var billingCategory: String?
    internal var dispute: Bool?
    //TODO still not ready in server
    internal var logoUrl: String?
    internal var settlementPeriod: String?
    internal var symbol: String?
    internal var settlementMonthPeriod: String?
    internal var iataInvoiceDate: String?
    
    
    internal required init?() {
    }
    
    required init?(map: Map) {
        
    }
    
    internal func mapping(map: Map) {
        status <- map[PropertyKey.status.rawValue]
        id <- map[PropertyKey.id.rawValue]
        number <- map[PropertyKey.number.rawValue]
        clientName <- map[PropertyKey.clientName.rawValue]
        clientEmail <- map[PropertyKey.clientEmail.rawValue]
        amount <- map[PropertyKey.amount.rawValue]
        dueDate <- map[PropertyKey.dueDate.rawValue]
        settlementAssetId <- map[PropertyKey.settlementAssetId.rawValue]
        paidAmount <- map[PropertyKey.paidAmount.rawValue]
        paymentAssetId <- map[PropertyKey.paymentAssetId.rawValue]
        paymentRequestId <- map[PropertyKey.paymentRequestId.rawValue]
        merchantId <- map[PropertyKey.merchantId.rawValue]
        employeeId <- map[PropertyKey.employeeId.rawValue]
        createdDate <- map[PropertyKey.createdDate.rawValue]
        note <- map[PropertyKey.note.rawValue]
        billingCategory <- map[PropertyKey.billingCategory.rawValue]
        dispute <- map[PropertyKey.dispute.rawValue]
        logoUrl <- map[PropertyKey.logoUrl.rawValue]
        settlementPeriod <- map[PropertyKey.settlementPeriod.rawValue]
        settlementMonthPeriod <- map[PropertyKey.settlementMonthPeriod.rawValue]
        iataInvoiceDate <- map[PropertyKey.iataInvoiceDate.rawValue]
        merchantName <- map[PropertyKey.merchantName.rawValue]
        iataInvoiceDate = DateUtils.formatDate(date: iataInvoiceDate)
        if let idValue = settlementAssetId, idValue.contains("USD") {
            self.symbol = "$"
        } else {
            self.symbol = "€"
        }
    }
}
