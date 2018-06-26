import Foundation
import PromiseKit

protocol ChangePasswordViewState: BaseViewState {
    
    func change(currentPassword: String, newPassword: String) -> Promise<Void>?
}
