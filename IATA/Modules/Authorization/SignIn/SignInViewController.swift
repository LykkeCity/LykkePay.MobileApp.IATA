import UIKit
import Material

class SignInViewController: BaseAuthViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var buildVersion: UILabel!
    @IBOutlet weak var titleWelcome: UILabel!
    @IBOutlet private weak var emailTextField: FloatTextField?
    @IBOutlet private weak var passwordField: FloatTextField?
    @IBOutlet private weak var btnLogin: UIButton?
    @IBOutlet weak var logoImg: UIImageView?
    
    private var isShown: Bool = false
    private var state: SignInViewState = DefaultSignInViewState() as SignInViewState
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = true

        self.titleWelcome.attributedText = Theme.shared.get2LineString(message: R.string.localizable.signInLabelWelcomeMessage())
        
        self.emailTextField?.delegate = self
        self.passwordField?.delegate = self

        self.buildVersion.text = version()
        Theme.shared.configureTextFieldStyle(self.emailTextField!, title: R.string.localizable.signInPlaceholderLogin())
        Theme.shared.configureTextFieldPasswordStyle(self.passwordField!, title: R.string.localizable.signInPlaceholderPassword())


        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.initNavBar()
    }
    
    
    private func initNavBar() {
        self.setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.navigationBar.barStyle = .black
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        self.navigationController?.navigationBar.layoutIfNeeded()
    }
    
    private func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "Build \(version) (version \(build))"
    }

    private func buttonClicked() {
        self.view.endEditing(true)
        self.emailTextField?.isErrorRevealed = false
        self.passwordField?.isErrorRevealed = false
        guard let email = self.emailTextField?.text!, let password = self.passwordField?.text! else {
            self.showErrorAlert(error: self.state.getError(R.string.localizable.commonErrorInternal()))
            return
        }
        self.signIn(email: email, password: state.getHashPass(email: email, password: password))
    }

    private func signIn(email: String, password: String) {
        self.state.signIn(email: email, password: password)
            .withSpinner(in: view)
            .then(execute: { [weak self] (tokenObject: TokenObject) -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.openValidationPinController(tokenObject: tokenObject)
            }).catch(execute: { [weak self] error -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.handleError(error: error)
            })
    }

    private func handleError(error: Error) {
        if (error is IATAOpError) {
            if (!(error as! IATAOpError).validationError.isEmpty) {
                self.handleSignInValidationError((error as! IATAOpError).validationError)
            } else {
                self.handleSingInError(error: error)
            }
        } else {
            self.showErrorAlert(error: error)
        }
    }
    
    private func openValidationPinController(tokenObject: TokenObject) {
        guard let email = self.emailTextField?.text, tokenObject.token != nil else {
            self.showErrorAlert(error: self.state.getError(R.string.localizable.commonErrorInternal()))
            return
        }

        self.state.savePreference(tokenObject: tokenObject, email: email)
        var viewController = UIViewController()
        if (UserPreference.shared.getUpdatePassword()!) {
            viewController =  ChangePasswordViewController()
        } else {
            viewController = PinViewController()
            if (UserPreference.shared.getUpdatePin())! {
                (viewController as! PinViewController).isValidation = false
            }
        }
        NavPushingUtil.shared.push(navigationController: self.navigationController,  controller: viewController)
        self.navigationController?.isNavigationBarHidden = false
    }

    private func handleSingInError(error : Error) {
        self.showErrorAlert(error: error)
    }

    private func handleSignInValidationError(_ listOfError: Dictionary<String, [String]>) {
        for item in listOfError {
            switch item.key {
            case PropertyValidationKey.email.rawValue:
                Theme.shared.showError(self.emailTextField, state.getError(item.key, values: item.value))
                break
            case PropertyValidationKey.password.rawValue:
                Theme.shared.showError(self.passwordField, state.getError(item.key, values: item.value))
                break
            default:
                break;
            }
        }
    }

    @IBAction func login(_ sender: Any) {
        buttonClicked()
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if let isHidden = self.logoImg?.isHidden, !isHidden, !isShown {
                self.view.frame.origin.y -= keyboardSize.height/2
                self.logoImg?.isHidden = true
                self.isShown = true
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let isHidden = self.logoImg?.isHidden, isHidden, isShown {
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            self.logoImg?.isHidden = false
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                self.view.frame.origin.y += keyboardSize.height/2
            }
            self.isShown = false
        }
    }
    
    
}
