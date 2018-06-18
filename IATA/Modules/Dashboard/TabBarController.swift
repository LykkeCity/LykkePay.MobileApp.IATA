

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    private let theme = Theme.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        tabBarSettings()
        
        var invoicesVC = InvoiceViewController()
        var walletsVC = WalletsViewController()
        var exchangeVC = WalletsViewController()
        var historyVC = HistoryViewController()
        var settingsVC = SettingsViewController()

        invoicesVC = generateTabBarItem(for: invoicesVC, normalImage: "ic_invoicesNormal", activeImage: "ic_invoicesActive",
                                        title:"TabBar.InvoicesItem.Title".localize())
        walletsVC = generateTabBarItem(for: walletsVC, normalImage: "ic_walletsNormal", activeImage: "ic_walletsActive",
                                       title: "TabBar.WalletsItem.Title".localize())
        exchangeVC = generateTabBarItem(for: exchangeVC, normalImage: "ic_exchangeNormal", activeImage: "ic_exchangeActive",
                                        title: "TabBar.ExchangeItem.Title".localize())
        historyVC = generateTabBarItem(for: historyVC, normalImage: "ic_historyNormal", activeImage: "ic_historyActive",
                                       title: "TabBar.HistoryItem.Title".localize())
        settingsVC = generateTabBarItem(for: settingsVC, normalImage: "ic_settingsNormal", activeImage: "ic_settingsActive",
                                        title: "TabBar.SettingsItem.Title".localize())
        let controllers = [invoicesVC, walletsVC, exchangeVC, historyVC, settingsVC]
        
        self.viewControllers = controllers.map { UINavigationController(rootViewController: $0)}
       
    }

    private func generateTabBarItem<T: UIViewController>(for viewController: T, normalImage: String, activeImage: String, title: String) -> T {
        viewController.tabBarItem.title = title
        viewController.tabBarItem.image = UIImage(named: normalImage)
        viewController.tabBarItem.selectedImage = UIImage(named: activeImage)
        viewController.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: theme.tabBarItemUnselectedColor], for: .normal)
        viewController.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], for: .selected)
        viewController.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -5)
        return viewController
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        navigationItem.title = item.title
    }

    private func tabBarSettings(){
        self.tabBar.barTintColor = theme.tabBarBackgroundColor
        self.tabBar.isTranslucent = false
        self.tabBarController?.tabBar.isHidden = false
    }

    
}
