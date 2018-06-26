import Foundation
import PromiseKit
import ObjectMapper

class DefaultDisputeState: DefaultBaseState<DisputeModel> {

    public lazy var service: PaymentService = DefaultPaymentService()
    
    internal required init?() {
        super.init()
    }

    func getDisputeListStringJson() -> Promise<String> {
        return self.service.getDisputeList()
    }

    func mapping(jsonString: String!) {
        let disputeList =  Mapper<DisputeListItem>().mapArray(JSONObject: jsonString.toJSON())
        prepareDisputeList(from: disputeList!)
    }

    private func prepareDisputeList(from disputeList: [DisputeListItem]) {
        for dispute in disputeList {
            let disputeModel = DisputeModel()
            let invoice = InvoiceModel()
            disputeModel.reason = dispute.disputeReason
            invoice?.logoUrl = dispute.logoUrl
            invoice?.clientName = dispute.clientName
            invoice?.iataInvoiceDate = dispute.iataInvoiceDate
            invoice?.settlementMonthPeriod = dispute.settlementMonthPeriod
            invoice?.number = dispute.number
            invoice?.amount = dispute.amount
            invoice?.symbol = dispute.symbol
            invoice?.billingCategory = dispute.billingCategory
            invoice?.status = dispute.status
            invoice?.dispute = dispute.dispute
            invoice?.merchantName = dispute.merchantName
            disputeModel.invoice = invoice
            items.append(disputeModel)
        }

    }
}
