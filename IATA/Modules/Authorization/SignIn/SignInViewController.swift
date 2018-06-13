
import UIKit
import MaterialTextField

class SignInViewController: BaseAuthViewController {
    
    @IBOutlet private weak var emailTextField: MFTextField!
    @IBOutlet private weak var passwordField: MFTextField!
    @IBOutlet private weak var btnLogin: UIButton!
    @IBOutlet weak var logoImg: UIImageView!
    
    private var state: SignInViewState = DefaultSignInViewState() as SignInViewState
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        Theme.shared.configureTextFieldStyle(emailTextField)
        Theme.shared.configureTextFieldPasswordStyle(passwordField)
        passwordField.isSecureTextEntry = true
        
        btnLogin.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if (!self.logoImg.isHidden) {
                self.view.frame.origin.y -= keyboardSize.height/2
                self.logoImg.isHidden = true
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y += keyboardSize.height/2
            self.logoImg.isHidden = false
        }
    }
    
    @objc private func buttonClicked() {
        self.view.endEditing(true)
        self.signIn(email: emailTextField.text!, password: passwordField.text!)//state.getHashPass(email: emailTextField.text!, password: passwordField.text!))
    }
    
    private func signIn(email: String, password: String) {
        state.signIn(email: email, password: password)
            .withSpinner(in: view)
            .then(execute: { [weak self] (tokenObject: TokenObject) -> Void in
                guard let strongSelf = self else {
                    return
                }
                CredentialManager.shared.saveTokenObject(tokenObject, userName: strongSelf.emailTextField.text)
                UserPreference.shared.saveForceUpdatePassword(tokenObject.forcePasswordUpdate)
                UserPreference.shared.saveForceUpdatePin(tokenObject.forcePasswordUpdate! ? true : tokenObject.forceUpdatePin)
                strongSelf.openValidationPinController()
            }).catch(execute: { [weak self] error -> Void in
                guard let strongSelf = self else {
                    return
                }
                if (!(error as! IATAOpError).validationError.isEmpty) {
                    strongSelf.handleSignInValidationError((error as! IATAOpError).validationError)
                } else {
                    strongSelf.handleSingInError(error: error)
                }
            })
    }
    
    private func openValidationPinController() {
        var viewController = UIViewController()
        if (UserPreference.shared.getUpdatePassword()!) {
            viewController =  ChangePasswordViewController()
        } else {
            viewController = PinViewController()
            if (UserPreference.shared.getUpdatePin())! {
                (viewController as! PinViewController).isValidation = false
            }
        }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func handleSingInError(error : Error) {
        showErrorAlert(error: error)
    }
    
    private func handleSignInValidationError(_ listOfError: Dictionary<String, [String]>) {
        for item in listOfError {
            switch item.key {
            case PropertyValidationKey.email.rawValue:
                emailTextField.setError(state.getError(item.key, values: item.value), animated: true)
                break
            case PropertyValidationKey.password.rawValue:
                passwordField.setError(state.getError(item.key, values: item.value), animated: true)
                break
            default:
                break;
            }
        }
    }
}
