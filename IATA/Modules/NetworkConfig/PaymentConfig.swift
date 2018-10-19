import Foundation

class PaymentConfig {
    
    public static let shared = PaymentConfig()
    
    public let invoices = "/invoices/inbox"
    public let makePayment = "/invoices/pay"
    public let amount = "/invoices/sum"
    public let getFilters = "/invoices/filter"

    public let wallets = "/merchantWallets"
    
    public let historyIndex = "/history/Index"

    public let makeDisputInvoice = "/invoices/dispute/mark"

    public let cancelDisputInvoice = "/invoices/dispute/cancel"

    public let disputeList = "/invoices/dispute/list"
    

    public let historyDetails = "/history/Details"

    public let payedHistoryDetails = "history/invoicelatestpaymentdetails"

    
    public let user = "/user"
    public let baseAssets = "/baseAsset/list"
    public let baseAsset = "/baseAsset"

    public let exchange = "/exchange/Execute"
    public let preExchange = "/exchange/PreExchange"
   
    public let assetsGetCashout = "/assets/cashout"
    public let cashOut = "/cashout"

}
