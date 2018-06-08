

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    private let color = Theme.init()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        tabBarSettings()
        var invoicesVC = WalletsViewController(nibName: "WalletsViewController", bundle: nil)
        var walletsVC = WalletsViewController(nibName: "WalletsViewController", bundle: nil)
        var exchangeVC = WalletsViewController(nibName: "WalletsViewController", bundle: nil)
        var historyVC = WalletsViewController(nibName: "WalletsViewController", bundle: nil)
        var settingsVC = SettingsViewController()

        invoicesVC = generateTabBarItem(for: invoicesVC, normalImage: "invoicesNormal", activeImage: "invoicesActive",
                                        title:"TabItem.Invoices.Title".localize())
        walletsVC = generateTabBarItem(for: walletsVC, normalImage: "walletsNormal", activeImage: "walletsActive",
                                       title: "TabItem.Wallets.Title".localize())
        exchangeVC = generateTabBarItem(for: exchangeVC, normalImage: "exchangeNormal", activeImage: "exchangeActive",
                                        title: "TabItem.Exchange.Title".localize())
        historyVC = generateTabBarItem(for: historyVC, normalImage: "historyNormal", activeImage: "historyActive",
                                       title: "TabItem.History.Title".localize())
        settingsVC = generateTabBarItem(for: settingsVC, normalImage: "settingsNormal", activeImage: "settingsActive",
                                        title: "TabItem.Settings.Title".localize())
        self.viewControllers = [invoicesVC, walletsVC, exchangeVC, historyVC, settingsVC]
    }

    private func generateTabBarItem<T: UIViewController>(for viewController: T, normalImage: String, activeImage: String, title: String) -> T {
        viewController.tabBarItem.title = title
        viewController.tabBarItem.image = UIImage(named: normalImage)
        viewController.tabBarItem.selectedImage = UIImage(named: activeImage)
        viewController.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: color.tabBarItemUnselectedColor], for: .normal)
        viewController.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], for: .selected)
        viewController.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -5)
        return viewController
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        navigationItem.title = item.title
    }

    private func tabBarSettings(){
        self.tabBar.barTintColor = color.tabBarBackgroundColor
        self.tabBar.isTranslucent = false
    }
}
