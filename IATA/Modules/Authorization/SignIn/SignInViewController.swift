import UIKit
import Material

class SignInViewController: BaseAuthViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var width: NSLayoutConstraint!
    @IBOutlet weak var height: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var centerConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var buildVersion: UILabel!
    @IBOutlet weak var titleWelcome: UILabel!
    @IBOutlet private weak var emailTextField: FloatTextField?
    @IBOutlet private weak var passwordField: FloatTextField?
    @IBOutlet private weak var btnLogin: UIButton?
    @IBOutlet weak var logoImg: UIImageView?
    @IBOutlet private weak var changeServerButton: UIButton!

    private var heightAnchorTitle: NSLayoutConstraint? = nil
    private var heightAnchorWelcome: NSLayoutConstraint? = nil
    private var isShown: Bool = false
    private var formCenterOriginal: CGFloat = 0
    private var state: SignInViewState = DefaultSignInViewState() as SignInViewState
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return PresentAnimation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.formCenterOriginal = topConstraint.constant
        self.navigationController?.delegate = self
        self.navigationController?.isNavigationBarHidden = true

        self.titleWelcome.attributedText = Theme.shared.get2LineString(message: R.string.localizable.signInLabelWelcomeMessage())
        
        self.emailTextField?.delegate = self
        self.passwordField?.delegate = self
        
        if #available(iOS 10.0, *) {
            self.emailTextField?.textContentType = UITextContentType("")
            self.passwordField?.textContentType = UITextContentType("")
        }

        self.buildVersion.text = version()
        Theme.shared.configureTextFieldStyle(self.emailTextField!, title: R.string.localizable.signInPlaceholderLogin())
        Theme.shared.configureTextFieldPasswordStyle(self.passwordField!, title: R.string.localizable.signInPlaceholderPassword())


        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        if #available(iOS 10.0, *) {
            self.emailTextField?.textContentType = UITextContentType("")
            self.passwordField?.textContentType = UITextContentType("")
        }

        setupChangeServerButton()

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

    private func setupChangeServerButton() {
        #if DEBUG
        changeServerButton.isHidden = false
        #endif
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

                PushNotificationHelper.registerInAzureHUB(with: tokenObject.notificationIds?.IDs)
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
        self.navigationController?.pushViewController(viewController, animated: true)
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

    @IBAction func changeServerButtonClicked(_ sender: UIButton) {
        var handlers: [(handler: ((UIAlertAction) -> Void), title: String)] = []
        BaseServerURLs.allCases().forEach { url in
            handlers.append((handler: { _ in
                NetworkConfig.shared.baseServerURL = url.getURL()
            }, title: url.value()))
        }

        generateChangeServerAllert(handlers: handlers)
    }


    @IBAction func login(_ sender: Any) {
        buttonClicked()
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        if !isShown {
            self.heightAnchorTitle = self.titleWelcome.heightAnchor.constraint(equalToConstant: 0)
            self.heightAnchorWelcome = self.titleLabel.heightAnchor.constraint(equalToConstant: 0)
            
            animateKeyboard(duration: duration, isActive: true, formCenterOriginal: 0, size: 80)
            isShown = true
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        if isShown {
            animateKeyboard(duration: duration, isActive: false, formCenterOriginal: self.formCenterOriginal, size: 110)
            self.isShown = false
        }
    }
    
    private func animateKeyboard(duration: Double, isActive: Bool, formCenterOriginal: CGFloat, size: CGFloat) {
        UIView.animate(withDuration: duration) {
            self.topConstraint.constant = formCenterOriginal
            self.heightAnchorTitle?.isActive = isActive
            self.heightAnchorWelcome?.isActive = isActive
            let alphaForTitles = isActive ? CGFloat(0) : CGFloat(1)
            self.titleWelcome.alpha = alphaForTitles
            self.titleLabel.alpha = alphaForTitles
            self.height.constant = size
            self.width.constant = size
            self.view.layoutIfNeeded()
        }
    }
}
