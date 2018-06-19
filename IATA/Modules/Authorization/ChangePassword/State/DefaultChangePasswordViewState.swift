import Foundation
import PromiseKit

class DefaultChangePasswordViewState: DefaultBaseViewState, ChangePasswordViewState {
    
    func change(currentPassword: String, newPassword: String) -> Promise<Void>? {
        return self.service.changePassword(oldPassword: currentPassword, newPassword: getHashPass(value: (newPassword + CredentialManager.shared.getUserName()!)))
    }

}
