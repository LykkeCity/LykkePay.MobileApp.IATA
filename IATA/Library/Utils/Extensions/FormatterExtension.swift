import Foundation

extension Formatter {
    
    static func formattedWithSeparator(value: String?) -> String {
        if let valueString = value  {
            let formatter = NumberFormatter()
            let doubleValue = formatter.number(from: valueString)?.doubleValue
            formatter.groupingSeparator = " "
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 3
            if !valueString.contains(".0"){
                formatter.minimumFractionDigits = 0
            } else if valueString.contains(".000") {
                formatter.minimumFractionDigits = 3
            } else if valueString.contains(".00") {
                formatter.minimumFractionDigits = 2
            } else if valueString.contains(".0") {
                formatter.minimumFractionDigits = 1
            }
            return formatter.string(for: doubleValue) ?? ""
        } else {
            return "0"
        }
    }
    
    
    static func formattedWithSeparator(valueDouble: Double??) -> String {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = " "
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 3
        return formatter.string(for: valueDouble) ?? ""
    }
    
    
    static func formattedToDouble(valueString: String?) -> Double? {
        if let valueString = valueString  {
            let formatter = NumberFormatter()
            formatter.groupingSeparator = " "
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 6
            return formatter.number(from: valueString)?.doubleValue
        } else {
            return 0.0
        }
    }
    
}
