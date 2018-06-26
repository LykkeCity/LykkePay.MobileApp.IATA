import UIKit
import JGProgressHUD

public class SpinnerController: NSObject {
    private var spinnerCounter = 0
    private weak var view: UIView?
    private var spinner: JGProgressHUD?
    
    public init(with view: UIView) {
        self.view = view
        super.init()
    }
    
    public func spinnerRequired() {
        spinnerCounter += 1
        updateSpinnerOnNextTick()
    }
    
    public func spinnerNotRequired() {
        spinnerCounter -= 1
        if spinnerCounter < 0 {
            print("Warning. SpinnerController.spinnerCounter < 0. Set breakpoint and check what is wrong.")
        }
        updateSpinnerOnNextTick()
    }
    
    private func updateSpinnerOnNextTick() {
        // to minimize show/hide calls delay counter decrease
        perform(#selector(updateSpinner), with: nil, afterDelay: 0.1)
    }
    
    @objc
    private func updateSpinner() {
        if spinnerCounter > 0 {
            showSpinnerIfNeed()
        } else {
            hideSpinnerIfNeed()
        }
    }
    
    private func showSpinnerIfNeed() {
        guard let view = view else {
            return
        }
        if spinner != nil {
            return
        }
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Loading"
        hud.show(in: view)
        spinner = hud
    }
    
    private func hideSpinnerIfNeed() {
        spinner?.dismiss()
        spinner = nil
    }
    
}
