import Foundation
import ObjectMapper

protocol LocalStorage {
    func set<T: BaseMappable>(value: T, for key: String)
    func get<T: BaseMappable>(for key: String) -> T?
    func remove(for key: String)
}
