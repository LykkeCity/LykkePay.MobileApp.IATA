import Foundation

class DateUtils {
    
    static let dateFormatter = DateFormatter()
    
    internal static func formatDate(date: String?) -> String? {
        if let date = date {
        dateFormatter.dateFormat = "YYYY-MM-DD"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "dd.MM.YYYY"
            return  dateFormatter.string(from: date!)
        } else {
            return date
        }
    }
}
