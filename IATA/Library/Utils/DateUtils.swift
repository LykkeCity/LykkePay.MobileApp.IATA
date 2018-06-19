import Foundation

public class DateUtils {
    
    static internal func formatDateFromFormat(dateString: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-ddTHH:mm:ss.SSSZ"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd.MM.yyyy"
        
        if let date = dateFormatterGet.date(from: dateString){
             return dateFormatterPrint.string(from: date)
        }
        return dateString
    }
}
