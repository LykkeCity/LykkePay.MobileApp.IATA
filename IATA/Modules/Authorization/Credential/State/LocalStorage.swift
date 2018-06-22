import Foundation
import ObjectMapper

protocol LocalStorage {
    func set<T: Mappable>(value: T, for key: String)
    func get<T: Mappable>(for key: String) -> T?
    func remove(for key: String)
}
