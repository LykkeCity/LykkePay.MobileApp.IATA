
import Foundation
import UIKit
import ObjectMapper

class DisputeListItem: Mappable {

    private enum PropertyKey: String {
        case disputeRaisedAt
        case disputeReason
        case merchantName
        case status
        case iataInvoiceDate
        case settlementMonthPeriod
        case logoUrl
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
        case symbol
    }

    internal var disputeRaisedAt: String?
    internal var disputeReason: String?
    internal var merchantName: String?
    internal var status: InvoiceStatuses?
    internal var iataInvoiceDate: String?
    internal var settlementMonthPeriod: String?
    internal var logoUrl: String?
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
    internal var symbol: String?

    internal required init?(map: Map) {
    }

    internal init() {}

    init(json: [String: Any]) {

    }

    internal func mapping(map: Map) {
        disputeRaisedAt <- map[PropertyKey.disputeRaisedAt.rawValue]
        disputeReason <- map[PropertyKey.disputeReason.rawValue]
        merchantName <- map[PropertyKey.merchantName.rawValue]
        status <- map[PropertyKey.status.rawValue]
        iataInvoiceDate <- map[PropertyKey.iataInvoiceDate.rawValue]
        settlementMonthPeriod <- map[PropertyKey.settlementMonthPeriod.rawValue]
        logoUrl <- map[PropertyKey.logoUrl.rawValue]
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
        merchantId <- map[PropertyKey.merchantName.rawValue]
        employeeId <- map[PropertyKey.employeeId.rawValue]
        note <- map[PropertyKey.note.rawValue]
        createdDate <- map[PropertyKey.createdDate.rawValue]
        billingCategory <- map[PropertyKey.billingCategory.rawValue]
        dispute <- map[PropertyKey.dispute.rawValue]

        if let idValue = settlementAssetId, idValue.contains("USD") {
            self.symbol = "$"
        } else {
            self.symbol = "€"
        }
    }
}

