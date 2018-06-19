

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    private let theme = Theme.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        tabBarSettings()
        
        var invoicesVC = InvoiceViewController()
        var walletsVC = WalletsViewController()
        var exchangeVC = ExhangeViewController()
        var historyVC = HistoryViewController()
        var settingsVC = SettingsViewController()

        invoicesVC = generateTabBarItem(for: invoicesVC, normalImage: R.image.ic_invoicesNormal.name, activeImage: R.image.ic_invoicesActive.name,
                                        title: R.string.localizable.tabBarInvoicesItemTitle())
        walletsVC = generateTabBarItem(for: walletsVC, normalImage: R.image.ic_walletsNormal.name, activeImage: R.image.ic_walletsActive.name,
                                       title: R.string.localizable.tabBarWalletsItemTitle())
        exchangeVC = generateTabBarItem(for: exchangeVC, normalImage: R.image.ic_exchangeNormal.name, activeImage: R.image.ic_exchangeActive.name,
                                        title: R.string.localizable.tabBarExchangeItemTitle())
        historyVC = generateTabBarItem(for: historyVC, normalImage: R.image.ic_historyNormal.name, activeImage: R.image.ic_historyActive.name,
                                       title: R.string.localizable.tabBarHistoryItemTitle())
        settingsVC = generateTabBarItem(for: settingsVC, normalImage: R.image.ic_settingsNormal.name, activeImage: R.image.ic_settingsActive.name,
                                        title: R.string.localizable.tabBarSettingsItemTitle())
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
