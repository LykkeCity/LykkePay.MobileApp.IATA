
import UIKit

class PinViewController: UIViewController {
    
    @IBOutlet weak var passwordStackView: UIStackView!
    @IBOutlet weak var labelTitle: UILabel!
    
    private var state: PinViewState = DefaultPinViewState() as PinViewState
    
    //MARK: Property
    var passwordContainerView: PasswordContainerView!
    let kPasswordDigit = 4
    var isValidation = true
    var countOfTry = 0
    var pinCode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initNavBar()
        //create PasswordContainerView
        self.passwordContainerView = PasswordContainerView.create(in: passwordStackView, digit: kPasswordDigit)
        self.passwordContainerView.delegate = self as PasswordInputCompleteProtocol
        self.passwordContainerView.touchAuthenticationEnabled = isValidation
        
        self.labelTitle.text = self.isValidation ? R.string.localizable.pinValidationTitle() : R.string.localizable.pinSetupTitle()
        
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
    
    
    private func initNavBar() {
        self.setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.leftBarButtonItem = getBackButton()
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
        NavPushingUtil.shared.pushDown(navigationController: self.navigationController, controller: SignInViewController())
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
        self.navigationController?.isNavigationBarHidden = true
        present(TabBarController(), animated: true, completion: nil)
        //NavPushingUtil.shared.pushDown(navigationController: self.navigationController, controller: TabBarController())
        self.navigationController?.navigationBar.barTintColor = Theme.init().navigationBarColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
    func validationFail() {
        self.countOfTry += 1
        self.passwordContainerView.wrongPassword()
        if (countOfTry > 2) {
            self.openSignIn()
        }
    }
    
    func reset() {
        self.passwordContainerView.clearInput()
        self.labelTitle.text = R.string.localizable.pinResubmitTitle()
    }
}

