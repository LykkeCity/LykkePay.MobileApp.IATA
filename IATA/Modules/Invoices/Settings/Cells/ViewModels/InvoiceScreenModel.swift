import Foundation

public func dataFromFile(_ filename: String) -> Data? {
    @objc class TestClass: NSObject { }
    
    let bundle = Bundle(for: TestClass.self)
    if let path = bundle.path(forResource: filename, ofType: "json") {
        return (try? Data(contentsOf: URL(fileURLWithPath: path)))
    }
    return nil
}

class InvoiceScreenModel {
    var airlines = [AirlinesInvoiceModel]()
    var billingCategories = [InvoiceModel]()
    var currencies = [InvoiceModel]()
    var paymentRange = InvoicePaymentRangeItemModel(min: 1000, max: 10000)
    var settlementPeriod = [InvoiceModel]()
    
    init?(data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any], let body = json["data"] as? [String: Any] {
                
                if let airlines = body["airlines"] as? [[String: Any]] {
                    self.airlines = airlines.map { AirlinesInvoiceModel(json: $0) }
                }
                
                if let billingCategories = body["billingCategories"] as? [[String: Any]] {
                    self.billingCategories = billingCategories.map { InvoiceModel(json: $0) }
                }
                 
                if let currencies = body["currencies"] as? [[String: Any]] {
                    self.currencies = currencies.map { InvoiceModel(json: $0) }
                }
                
                if let settlementPeriod = body["settlementPeriod"] as? [[String: Any]] {
                    self.settlementPeriod = settlementPeriod.map { InvoiceModel(json: $0) }
                }
            }
        } catch {
            print("Error deserializing JSON: \(error)")
            return nil
        }
    }
}
