import UIKit
import CoreData
import Fabric
import Crashlytics
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
   
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

        return true
    }

    private func turnOffLayoutWarnings() {
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
    }

    internal func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushNotificationHelper.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        PushNotificationHelper.registerInAzureHUB(with: "")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
//        let uiAlert = UIAlertController(title: "Notif", message: "", preferredStyle: .alert)
//        UIApplication.topViewController()?.present(uiAlert, animated: true, completion: nil)
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReceivedNotification"), object:userInfo)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
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
            return navigationWas
        }
        let navigationController = UINavigationController(rootViewController: makeRootViewController())
        navigationController.isNavigationBarHidden = true
        window?.rootViewController = navigationController
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

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

