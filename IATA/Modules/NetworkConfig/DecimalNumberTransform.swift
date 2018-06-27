import UIKit
import Foundation
import ObjectMapper

extension NSDecimalNumber {
    func rounded(places: Int) -> NSDecimalNumber {
        var decimalValue = self.decimalValue
        var result: Decimal = 0
        NSDecimalRound(&result, &decimalValue, places, .plain)
        return NSDecimalNumber(decimal: result)
    }
}
