import UIKit
import Material

class ChangePasswordViewController: BaseAuthViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var oldPasswordField: FloatTextField?
    @IBOutlet weak var newPasswordField: FloatTextField?
    @IBOutlet weak var newPasswordAgainField: FloatTextField?
    @IBOutlet weak var changeButton: UIButton?
    
    private var state: ChangePasswordViewState = DefaultChangePasswordViewState() as ChangePasswordViewState
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return PresentAnimation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.delegate = self
        self.initView()
        self.oldPasswordField?.delegate = self
        self.newPasswordField?.delegate = self
        self.newPasswordAgainField?.delegate = self
        self.setNeedsStatusBarAppearanceUpdate()
        self.initNavBar()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.initNavBar()
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    
    @IBAction func textFieldChanged(_ sender: Any) {
        self.changeState(state: self.isReady())
    }
    
    @IBAction func clickCancel(_ sender: Any) {
        self.view.endEditing(true)
        CredentialManager.shared.clearSavedData()
        self.navigationController?.pushViewController(SignInViewController(), animated: true)
    }
    
    private func initView() {
        self.initNavBar()
        Theme.shared.configureTextFieldPasswordStyle(self.oldPasswordField, title: "ChangePassword.Placeholder.CurrentPassword")
        Theme.shared.configureTextFieldPasswordStyle(self.newPasswordField, title: "ChangePassword.Placeholder.NewPassword")
        Theme.shared.configureTextFieldPasswordStyle(self.newPasswordAgainField, title: "ChangePassword.Placeholder.NewPasswordAgain")
        
        self.newPasswordField?.delegate = self
        self.newPasswordAgainField?.delegate = self
        self.oldPasswordField?.delegate = self
        
        self.changeButton?.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
        self.changeState(state: false)
    }
    
    private func initNavBar() {
        self.setNeedsStatusBarAppearanceUpdate()
        self.navBar.barStyle = .black
        
        self.navigationController?.isNavigationBarHidden = true
        self.navView.backgroundColor = Theme.shared.greyNavBar
        self.navBar.barTintColor = Theme.shared.greyNavBar
        self.navBar.tintColor = Theme.shared.navBarTitle
        self.navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: Theme.shared.navBarTitle]
        self.navBar.isTranslucent = false
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        self.navBar.layoutIfNeeded()
        self.setNeedsStatusBarAppearanceUpdate()
        initBackButton()
        initTitle()
        
    }
    
    private func initBackButton() {
        let backButton = Theme.shared.getCancel(title: R.string.localizable.commonNavBarCancel(), color: Theme.shared.navBarTitle)
        backButton.addTarget(self, action: #selector(clickCancel), for: .touchUpInside)
        
        let backItem = UIBarButtonItem(customView: backButton)
        self.navItem.leftBarButtonItem = backItem
    }
    
    private func initTitle() {
        let titleLabel = Theme.shared.getTitle(title: R.string.localizable.changePasswordNavBarTitle(), color: Theme.shared.navBarTitle)
        self.navItem.titleView = titleLabel
    }
    
    @objc private func buttonClicked() {
        self.view.endEditing(true)
        var isReady = false
        if let newPass = self.newPasswordField?.text, let newPassAgain = self.newPasswordAgainField?.text {
            isReady =  newPass.elementsEqual(newPassAgain)
        }
        
        if (!isReady) {
            Theme.shared.showError(self.newPasswordAgainField, R.string.localizable.changePasswordFieldNotEqualsError())
        } else {
            guard let oldPassword = self.oldPasswordField?.text, let newPassword = self.newPasswordField?.text else {
                return
            }
            self.state.change(currentPassword: oldPassword, newPassword: newPassword)?
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

                    if (error is IATAOpError) {
                        if (!(error as! IATAOpError).validationError.isEmpty) {
                            strongSelf.handleSignInValidationError((error as! IATAOpError).validationError)
                        } else {
                            strongSelf.handleError(error: error)
                        }
                    } else {
                        strongSelf.showErrorAlert(error: error)
                    }
                })
        }
    }
    
    private func handleError(error: Error) {
        super.showErrorAlert(error: error)
    }
    
    private func handleSignInValidationError(_ listOfError: Dictionary<String, [String]>) {
        for item in listOfError {
            switch item.key {
            case PropertyValidationKey.currentPasssword.rawValue:
                Theme.shared.showError(self.oldPasswordField, state.getError(item.key, values: item.value))
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
    
    private func setUpTextFields() {
        if (!self.isHasError()) {
            self.newPasswordAgainField?.isErrorRevealed = false
        }
    }
    
    private func isReady() -> Bool {
        guard let currentPassword = self.oldPasswordField?.text else {
            return false
        }
        return !currentPassword.isEmpty && !self.isHasError()
    }
    
    private func isHasError() -> Bool {
        guard let newPass = self.newPasswordField?.text, let newPassAgain = self.newPasswordAgainField?.text else {
            return false
        }
        return newPass.isEmpty || newPassAgain.isEmpty
    }
    
    private func changeState(state: Bool) {
        self.changeButton?.alpha = state ? 1.0 : 0.5
        self.changeButton?.isEnabled = state
        self.setUpTextFields()
    }
    
}
