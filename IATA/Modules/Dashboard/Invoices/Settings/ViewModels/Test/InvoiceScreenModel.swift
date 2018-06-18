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
    var airlines = [InvoiceSettingAirlinesModel]()
    var billingCategories = [InvoiceSettingAirlinesModel]()
    var currencies = [InvoiceSettingAirlinesModel]()
    var paymentRange = InvoiceSettingPaymentRangeItemModel(min: FilterPreference.shared.getMinValue(), max: FilterPreference.shared.getMaxValue())
    var settlementPeriod = [InvoiceSettingAirlinesModel]()
    
    init?(data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any], let body = json["data"] as? [String: Any] {
                
                if let airlines = body["airlines"] as? [[String: Any]] {
                    self.airlines = airlines.map { InvoiceSettingAirlinesModel(json: $0) }
                }
                
                if let billingCategories = body["billingCategories"] as? [[String: Any]] {
                    self.billingCategories = billingCategories.map { InvoiceSettingAirlinesModel(json: $0) }
                }
                 
                if let currencies = body["currencies"] as? [[String: Any]] {
      
                    self.currencies = currencies.map { InvoiceSettingAirlinesModel(json: $0) }
                }
                
                if let settlementPeriod = body["settlementPeriod"] as? [[String: Any]] {
                    self.settlementPeriod = settlementPeriod.map { InvoiceSettingAirlinesModel(json: $0) }
                }
            }
        } catch {
            print("Error deserializing JSON: \(error)")
            return nil
        }
    }
}
