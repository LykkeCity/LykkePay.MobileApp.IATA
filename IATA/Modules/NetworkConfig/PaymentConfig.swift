import Foundation

class PaymentConfig {
    
    public static let shared = PaymentConfig()
    
    public let invoices = "/invoices/inbox"
    public let makePayment = "/invoices/pay"
    public let amount = "/invoices/sum"

    public let wallets = "/merchantWallets"
    
    public let historyIndex = "/history/Index"

    public let makeDisputInvoice = "/invoices/dispute/mark"

    public let cancelDisputInvoice = "/invoices/dispute/cancel"

    public let disputeList = "/invoices/dispute/list"
    
}
