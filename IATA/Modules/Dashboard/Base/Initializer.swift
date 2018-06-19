import UIKit

protocol Initializer {
    
    func getTitle() -> String?
    
    func getTableView() -> UITableView
    
    func registerCells()
    
}
