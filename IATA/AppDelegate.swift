import UIKit
import CoreData
import Fabric
import Crashlytics
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UINavigationControllerDelegate {
   
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let name = String(describing: fromVC.classForCoder)
        if name.contains("Pin") {
            return PresentDownAnimation()
        } else {
            return PresentAnimation()
        }
    }
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        initWindow()
        let navigationController = switchToNavigationControllerIfNeed()
        let viewController = makeRootViewController()
        let name = String(describing: navigationController.visibleViewController?.classForCoder)
        let newName = String(describing: viewController.classForCoder)
        if (!name.contains(newName)) {
            navigationController.pushViewController(makeRootViewController(), animated: true)
        }
        turnOffLayoutWarnings()

        #if !TARGET_IPHONE_SIMULATOR
        PushNotificationHelper.register(with: application)
        #endif

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }

        setServerURL()

        return true
    }

    private func setServerURL() {
        NetworkConfig.shared.baseServerURL = UserPreference.shared.getBaseURL()
    }

    private func turnOffLayoutWarnings() {
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
    }

    internal func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushNotificationHelper.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    internal func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        PushNotificationHelper.application(application, didRegisterUserNotificationSettings: notificationSettings)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        UserPreference.shared.saveLastOpenTime(date: getCurrentTime())
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        UserPreference.shared.saveLastOpenTime(date: getCurrentTime())
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        var lastOpenTime = UserPreference.shared.getLastOpenTime()
        if lastOpenTime == nil {
            lastOpenTime = getCurrentTime()
        }
        let navigationController = switchToNavigationControllerIfNeed()
        let viewController = makeRootViewController()
        let name = String(describing: navigationController.visibleViewController?.classForCoder)
        let newName = String(describing: viewController.classForCoder)
        if (!name.contains(newName) && (getCurrentTime() - lastOpenTime!) > 30) {
            navigationController.pushViewController(makeRootViewController(), animated: true)
        }
        UserPreference.shared.saveLastOpenTime(date: getCurrentTime())
    }
    
    private func getCurrentTime() -> Int64 {
        return Int64(Date().timeIntervalSince1970)
    }
    private func initWindow() {
        window = UIWindow()
        window?.makeKeyAndVisible()
    }
    
    private func switchToNavigationControllerIfNeed() -> UINavigationController {
        if let navigationWas = window?.rootViewController as? UINavigationController {
            navigationWas.delegate = self
            return navigationWas
        }
        let navigationController = UINavigationController(rootViewController: makeRootViewController())
        navigationController.isNavigationBarHidden = true
        window?.rootViewController = navigationController
        navigationController.delegate = self
        return navigationController
    }
    
    private func makeRootViewController() -> UIViewController {
        var viewController = UIViewController()
        if (!CredentialManager.shared.isLogged) {
            viewController = SignInViewController()
        } else if (UserPreference.shared.getUpdatePassword()!) {
            viewController = ChangePasswordViewController()
        } else {
            viewController = PinViewController()
            if (UserPreference.shared.getUpdatePin()!) {
                (viewController as! PinViewController).isValidation = false
            }
        }
        return viewController
    }
}

extension AppDelegate:  UNUserNotificationCenterDelegate {
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}
