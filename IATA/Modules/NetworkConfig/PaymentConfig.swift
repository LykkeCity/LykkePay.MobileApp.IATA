import Foundation

class PaymentConfig {
    
    public static let shared = PaymentConfig()
    
    public let invoices = "/invoices/inbox"
    public let makePayment = "/invoices/pay"
    public let amount = "/invoices/sum"
    
}
