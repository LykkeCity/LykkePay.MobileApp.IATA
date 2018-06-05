
import UIKit
import MaterialTextField

class SignInViewController: UIViewController {
    
    @IBOutlet private weak var emailTextField: MFTextField!
    @IBOutlet private weak var passwordField: MFTextField!
    @IBOutlet private weak var btnLogin: UIButton!
    
    private var state: SignInViewState = DefaultSignInViewState() as SignInViewState
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Theme.shared.configureTextFieldStyle(emailTextField)
        Theme.shared.configureTextFieldStyle(passwordField)
        btnLogin.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
    }
    
    @objc private func buttonClicked() {
        self.signIn(email: emailTextField.text!, password: state.getHashPass(email: emailTextField.text!, password: passwordField.text!))
    }
    
    private func signIn(email: String, password: String) {
        state.signIn(email: email, password: password)
            .withSpinner(in: view)
            .always { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                
                //  strongSelf.credential = Credential(username: username, password: password)
            }
            .then(execute: { [weak self] (tokenObject: TokenObject) -> Void in
                guard let strongSelf = self else {
                    return
                }
                
                //     strongSelf.saveCredential(tokenObject: tokenObject)
                //   SessionController.shared.onSignIn(isTermsAccepted: tokenObject.hasAcceptTermsAndConditions)
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
    
    private func handleSingInError(error : Error) {
        if (error is IATAOpError) {
            let uiAlert = UIAlertController(title: "Common.Title.Error".localize(), message: (error as! IATAOpError).localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
            self.present(uiAlert, animated: true, completion: nil)
            
            uiAlert.addAction(UIAlertAction(title: "Common.PositiveButton.Ok".localize(), style: .default, handler: nil))
        }
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
