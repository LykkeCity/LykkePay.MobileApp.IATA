import Foundation

extension Formatter {
    
    static func formattedWithSeparator(value: String?) -> String {
        if let valueString = value  {
            let doubleValue = Double(valueString)
            let formatter = NumberFormatter()
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
    
    static func formattedWithSeparator(value: String?, canBeZero: Bool) -> String {
        if let valueString = value  {
            let doubleValue = Double(valueString)
            let formatter = NumberFormatter()
            formatter.groupingSeparator = " "
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 3
            if !valueString.contains(".0") || canBeZero {
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
    
}
