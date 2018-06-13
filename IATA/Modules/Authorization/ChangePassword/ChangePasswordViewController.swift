import UIKit
import MaterialTextField

class ChangePasswordViewController: BaseAuthViewController, UITextFieldDelegate {
    
    @IBOutlet weak var oldPasswordField: MFTextField!
    @IBOutlet weak var newPasswordField: MFTextField!
    @IBOutlet weak var newPasswordAgainField: MFTextField!
    @IBOutlet weak var changeButton: UIButton!
    
    private var state: ChangePasswordViewState = DefaultChangePasswordViewState() as ChangePasswordViewState
    
    @IBAction func textFieldChanged(_ sender: Any) {
        self.changeState(state: self.isReady())
    }
    
    @IBAction func clickCancel(_ sender: Any) {
        CredentialManager.shared.clearSavedData()
        self.navigationController?.pushViewController(SignInViewController(), animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
    }
    
    private func initView() {
        self.initNavBar()
        Theme.shared.configureTextFieldPasswordStyle(oldPasswordField)
        Theme.shared.configureTextFieldPasswordStyle(newPasswordField)
        Theme.shared.configureTextFieldPasswordStyle(newPasswordAgainField)
        
        self.newPasswordField.delegate = self
        self.newPasswordAgainField.delegate = self
        self.oldPasswordField.delegate = self
        
        self.changeButton.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
        self.changeState(state: false)
    }
    
    private func initNavBar() {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = Theme.shared.navBarTitle
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: Theme.shared.navBarTitle]
        self.navigationController?.navigationBar.isTranslucent = false
        
        initBackButton()
        initTitle()
        
    }
    
    private func initBackButton() {
        let backButton = Theme.shared.getCancel(title: "Common.NavBar.Cancel".localize(), color: Theme.shared.navBarTitle)
        backButton.addTarget(self, action: #selector(clickCancel), for: .touchUpInside)
        
        let backItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backItem
    }
    
    private func initTitle() {
        let titleLabel = Theme.shared.getTitle(title: "ChangePassword.NavBar.Title".localize(), color: Theme.shared.navBarTitle)
        self.navigationItem.titleView = titleLabel
    }
    
    @objc private func buttonClicked() {
        self.state.change(currentPassword: oldPasswordField.text!, newPassword: newPasswordField.text!)?
            .withSpinner(in: view)
            .then(execute: { [weak self] (ob: Void) -> Void in
                guard let strongSelf = self else {
                    return
                }
                UserPreference.shared.saveForceUpdatePassword(false)
                strongSelf.openPinController()
            }).catch(execute: { [weak self] error -> Void in
                guard let strongSelf = self else {
                    return
                }
                if (!(error as! IATAOpError).validationError.isEmpty) {
                    strongSelf.handleSignInValidationError((error as! IATAOpError).validationError)
                } else {
                    strongSelf.handleError(error: error)
                }
            })
    }
    
    private func handleError(error: Error) {
        super.showErrorAlert(error: error)
    }
    
    private func handleSignInValidationError(_ listOfError: Dictionary<String, [String]>) {
        for item in listOfError {
            switch item.key {
            case PropertyValidationKey.currentPasssword.rawValue:
                self.oldPasswordField.setError(state.getError(item.key, values: item.value), animated: true)
                break
            default:
                break;
            }
        }
    }
    
    private func openPinController() {
        let viewController =  PinViewController()
        viewController.isValidation = false
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    fileprivate func setUpTextFields() {
        if (self.isHasError()) {
            let userInfo = [NSLocalizedDescriptionKey: "ChangePassword.FieldNotEquals.Error".localize()]
            let error = NSError(domain: "", code: 123, userInfo: userInfo)
            self.newPasswordAgainField.setError(error, animated: true)
            
        } else {
            self.newPasswordAgainField.setError(nil, animated: true)
        }
    }
    
    fileprivate func isReady() -> Bool {
        return !self.oldPasswordField.text!.isEmpty && self.isHasError()
    }
    
    fileprivate func isHasError() -> Bool {
        return !self.newPasswordField.text!.isEmpty &&
            self.newPasswordField.text!.elementsEqual(self.newPasswordAgainField.text!)
    }
    
    fileprivate func changeState(state: Bool) {
        self.changeButton.alpha = state ? 1.0 : 0.5
        self.changeButton.isEnabled = state
    }
    
}
