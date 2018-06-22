import UIKit
import CoreData
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
   
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        initWindow()
        _ = switchToNavigationControllerIfNeed()
        return true
    }
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        let navigationController = switchToNavigationControllerIfNeed()
        let viewController = makeRootViewController()
        let name = String(describing: navigationController.visibleViewController?.classForCoder)
        let newName = String(describing: viewController.classForCoder)
        if (!name.contains(newName)) {
            navigationController.pushViewController(makeRootViewController(), animated: true)
        }
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

