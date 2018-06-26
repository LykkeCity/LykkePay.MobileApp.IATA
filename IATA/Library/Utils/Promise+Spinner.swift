import Foundation
import PromiseKit

extension Promise {
    public func withSpinner(in view: UIView) -> Promise<T> {
        view.spinnerController.spinnerRequired()
        self.always {
            view.spinnerController.spinnerNotRequired()
        }
        return self
    }
    
    public func withErrorHandler(_ errorHandler: ErrorHandler) -> Promise<T> {
        self.catch { (error) in
            errorHandler.handleError(error)
        }
        return self
    }
}
