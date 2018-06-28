
import UIKit

class PinViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var passwordStackView: UIStackView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    
    private var state: PinViewState = DefaultPinViewState() as PinViewState
    
    //MARK: Property
    var passwordContainerView: PasswordContainerView!
    let kPasswordDigit = 4
    var isValidation = true
    var completion: (() -> Void) = {}
    var isValidationTransaction = false
    var messageTouch: String? = nil
    var countOfTry = 0
    var pinCode = ""
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return PresentDownAnimation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initNavBar()
        self.navigationController?.delegate = self
        //create PasswordContainerView
        self.passwordContainerView = PasswordContainerView.create(in: passwordStackView, digit: kPasswordDigit)
        self.passwordContainerView.delegate = self as PasswordInputCompleteProtocol
        self.passwordContainerView.touchAuthenticationEnabled = isValidation
        
        self.labelTitle.text = self.isValidation ? R.string.localizable.pinValidationTitle() : R.string.localizable.pinSetupTitle()
        
        self.initNavBar()
        
        if self.isValidationTransaction, let message = messageTouch {
            self.passwordContainerView.touchAuthenticationReason = message
            self.passwordContainerView.touchAuthenticationAction(self.passwordContainerView.touchAuthenticationButton)
        }
    }
    
    @IBAction func clickCancel(_ sender: Any) {
        openSignIn()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    private func initNavBar() {
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.isNavigationBarHidden = true
        if self.isValidationTransaction {
            self.cancelBtn.isHidden = true
        } 
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = Theme.shared.navBarTitle
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: Theme.shared.navBarTitle]
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        self.navigationController?.navigationBar.layoutIfNeeded()
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    
    private func getBackButton() -> UIBarButtonItem {
        let backButton = Theme.shared.getCancel(title: R.string.localizable.commonNavBarCancel(), color: Theme.shared.navBarTitle)
        backButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        
        return UIBarButtonItem(customView: backButton)
    }
    
    @objc func cancel(_ sender: Any) {
        self.openSignIn()
    }
    
    func openSignIn() {
        CredentialManager.shared.clearSavedData()
        self.navigationController?.pushViewController(SignInViewController(), animated: true)
    }
}

extension PinViewController: PasswordInputCompleteProtocol {
    func passwordInputComplete(_ passwordContainerView: PasswordContainerView, input: String) {
        self.isValidation ? validation(input) : savePin(input)
    }
    
    func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error: Error?) {
        if success {
            self.validationSuccess()
        } else {
            self.passwordContainerView.clearInput()
        }
    }
}

private extension PinViewController {
    
    func savePin(_ input: String) -> Void {
        if (pinCode.isEmpty) {
            self.pinCode = input
            self.reset()
        } else if (pinCode.elementsEqual(input)) {
            self.state.savePin(pin: input)
                .withSpinner(in: view)
                .then(execute: { [weak self] (result: Void) -> Void in
                    guard let strongSelf = self else {
                        return
                    }
                    UserPreference.shared.saveForceUpdatePin(false)
                    strongSelf.validationSuccess()
                }).catch(execute: { [weak self] error -> Void in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.validationFail()
                })
        } else {
            self.passwordContainerView.wrongPassword()
        }
    }
    
    func validation(_ input: String) -> Void {
        self.state.validatePin(pin: input)
            .withSpinner(in: view)
            .then(execute: { [weak self] (result: PinValidationResponse) -> Void in
                guard let strongSelf = self else {
                    return
                }
                if (result.passed)! {
                    strongSelf.validationSuccess()
                } else {
                    strongSelf.validationFail()
                }
            }).catch(execute: { [weak self] error -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.validationFail()
            })
    }
    
    func validationSuccess() {
        if isValidationTransaction {
            self.dismiss(animated: true, completion: completion)
        } else {
            self.navigationController?.isNavigationBarHidden = true
            self.navigationController?.pushViewController(TabBarController(), animated: true)
            
            self.navigationController?.navigationBar.barTintColor = Theme.init().navigationBarColor
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        }
    }
    
    func validationFail() {
        self.countOfTry += 1
        self.passwordContainerView.wrongPassword()
        if (countOfTry > 2) {
            if isValidationTransaction {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.openSignIn()
            }
        }
    }
    
    func reset() {
        self.passwordContainerView.clearInput()
        self.labelTitle.text = R.string.localizable.pinResubmitTitle()
    }
}

