import UIKit
import CoreData
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
   
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

        return true
    }

    private func turnOffLayoutWarnings() {
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
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
    
    
    // MARK: - Core Data stack
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "IATA")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        
    }
    
}

