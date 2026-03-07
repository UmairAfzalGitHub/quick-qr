//
//  TabBarController.swift
//  Quick QR
//
//  Created by Umair Afzal on 28/08/2025.
//

import UIKit
import IOS_Helpers

class TabBarController: UITabBarController {
    
    // MARK: - Properties
    var adCounter = 0

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupTabBarAppearance()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Ensure tab bar is visible
        tabBar.isHidden = false
    }
    
    // MARK: - Setup
    private func setupViewControllers() {
        // Create view controllers
        let createVC = HomeViewController()
        createVC.view.backgroundColor = .systemBackground
        createVC.title = Strings.Label.chooseType
        let createNavController = UINavigationController(rootViewController: createVC)
        
        let favoriteVC = FavouriteViewController()
        favoriteVC.view.backgroundColor = .systemBackground
        favoriteVC.title = Strings.Label.favorite
        let favoriteNavController = UINavigationController(rootViewController: favoriteVC)
        
        let scanVC = ScannerViewController()
        scanVC.view.backgroundColor = .systemBackground
        scanVC.title = Strings.Label.scan
        let scanNavController = UINavigationController(rootViewController: scanVC)
        
        // Pre-warm scanning engines for instant gallery scanning
        ScannerViewController.preWarmEngines()
        
        let historyVC = HistoryViewController()
        historyVC.view.backgroundColor = .systemBackground
        historyVC.title = Strings.Label.history
        let historyNavController = UINavigationController(rootViewController: historyVC)
        
        let settingsVC = SettingsViewController()
        settingsVC.view.backgroundColor = .systemBackground
        settingsVC.title = Strings.Label.settings
        let settingsNavController = UINavigationController(rootViewController: settingsVC)
        
        let createImage   = UIImage(named: "create-tabbar-icon")?.withRenderingMode(.alwaysTemplate)
        let favoriteImage = UIImage(named: "heart-tabbar-icon")?.withRenderingMode(.alwaysTemplate)
        let scanImage     = UIImage(named: "scan")?.withRenderingMode(.alwaysTemplate)
        let historyImage  = UIImage(named: "history-tabbar-icon")?.withRenderingMode(.alwaysTemplate)
        let settingsImage = UIImage(named: "settings-tabbar-icon")?.withRenderingMode(.alwaysTemplate)
        
        let createItem = UITabBarItem(title: Strings.Label.create, image: createImage, tag: 0)
        let favoriteItem = UITabBarItem(title: Strings.Label.favorite, image: favoriteImage, tag: 1)
        let scanItem = UITabBarItem(title: Strings.Label.scan, image: scanImage, tag: 2)
        let historyItem = UITabBarItem(title: Strings.Label.history, image: historyImage, tag: 3)
        let settingsItem = UITabBarItem(title: Strings.Label.settings, image: settingsImage, tag: 4)
        
        createNavController.tabBarItem = createItem
        favoriteNavController.tabBarItem = favoriteItem
        scanNavController.tabBarItem = scanItem
        historyNavController.tabBarItem = historyItem
        settingsNavController.tabBarItem = settingsItem
        
        // Set view controllers
        self.viewControllers = [createNavController,
                                favoriteNavController,
                                scanNavController,
                                historyNavController,
                                settingsNavController]
        
        // Start with scan tab selected
        self.selectedIndex = 0
    }
    
    private func setupTabBarAppearance() {
        // Set tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .white
        
        // Configure item appearance
        let itemAppearance = UITabBarItemAppearance()
        
        // Normal state
        itemAppearance.normal.iconColor = UIColor.customColor(fromHex: "1B2137")
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.customColor(fromHex: "1B2137")]
        
        // Selected state
        itemAppearance.selected.iconColor = .appPrimary
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.appPrimary]
        
        // Apply to all tab bar item appearances
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        
        // Apply appearance
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        
        // Make sure tab bar is visible and opaque
        tabBar.isTranslucent = false
        tabBar.backgroundColor = .white
        
        // Set delegate to handle tab selection
        delegate = self
    }
    
    
    // MARK: - Factory Method
    static func createTabBarController() -> TabBarController {
        return TabBarController()
    }
    
    func setTabBarVisibility(_ hidden: Bool) {
        tabBar.isHidden = hidden
    }
}

// MARK: - UITabBarControllerDelegate
extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        adCounter += 1

        guard adCounter >= RemoteConfigManager.shared.maxInterstitalAdCounter else {
            return
        }
        AdManager.shared.showInterstitial(adId: RemoteConfigManager.shared.interstitial) { [weak self] _ in
            self?.adCounter = 0
            AdManager.shared.loadInterstitialAd(id: RemoteConfigManager.shared.interstitial)
        }
    }
}

