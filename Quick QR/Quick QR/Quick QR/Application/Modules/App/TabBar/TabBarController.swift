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
    private let centerButton = UIButton(type: .custom)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupTabBarAppearance()
        setupCenterButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        positionCenterButton()
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
        createVC.title = "Choose Type"
        let createNavController = UINavigationController(rootViewController: createVC)

        let favoriteVC = FavouriteViewController()
        favoriteVC.view.backgroundColor = .systemBackground
        favoriteVC.title = "Favorite"
        let favoriteNavController = UINavigationController(rootViewController: favoriteVC)

        let scanVC = UIViewController()
        scanVC.view.backgroundColor = .systemBackground
        scanVC.title = "" // Empty title for center tab
        
        let historyVC = HistoryViewController()
        historyVC.view.backgroundColor = .systemBackground
        historyVC.title = "History"
        let historyNavController = UINavigationController(rootViewController: historyVC)

        let settingsVC = UIViewController()
        settingsVC.view.backgroundColor = .systemBackground
        settingsVC.title = "Settings"
        
        // Configure tab bar items with larger images
        let createConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let favoriteConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let historyConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let settingsConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        
        let createImage = UIImage(systemName: "plus.square", withConfiguration: createConfig)
        let favoriteImage = UIImage(systemName: "heart", withConfiguration: favoriteConfig)
        let historyImage = UIImage(systemName: "clock", withConfiguration: historyConfig)
        let settingsImage = UIImage(systemName: "gear", withConfiguration: settingsConfig)
        
        let createItem = UITabBarItem(title: "Create", image: createImage, tag: 0)
        let favoriteItem = UITabBarItem(title: "Favorite", image: favoriteImage, tag: 1)
        // Center tab is invisible but takes up space
        let scanItem = UITabBarItem(title: "", image: UIImage(), tag: 2)
        let historyItem = UITabBarItem(title: "History", image: historyImage, tag: 3)
        let settingsItem = UITabBarItem(title: "Settings", image: settingsImage, tag: 4)
        
        createVC.tabBarItem = createItem
        favoriteVC.tabBarItem = favoriteItem
        scanVC.tabBarItem = scanItem
        historyVC.tabBarItem = historyItem
        settingsVC.tabBarItem = settingsItem
        
        // Set view controllers
        self.viewControllers = [createNavController,
                                favoriteNavController,
                                scanVC,
                                historyNavController,
                                settingsVC]
        
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
    
    private func setupCenterButton() {
        // Use the 'scan' image from assets catalog
        let scanImage = UIImage(named: "scan")
        centerButton.setImage(scanImage, for: .normal)
//        centerButton.tintColor = .white
        centerButton.backgroundColor = .white
        
        // Make button perfectly circular
        centerButton.layer.cornerRadius = 30
        
        // Add white border to create outer circle effect
        centerButton.layer.borderWidth = 2.0
        centerButton.layer.borderColor = UIColor.appPrimary.cgColor
        
        centerButton.addTarget(self, action: #selector(centerButtonTapped), for: .touchUpInside)
        
        // Add shadow for better visual effect
        centerButton.layer.shadowColor = UIColor.appPrimary.cgColor
        centerButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        centerButton.layer.shadowRadius = 8
        centerButton.layer.shadowOpacity = 0.4
        
        // Add to view
        view.addSubview(centerButton)
        view.bringSubviewToFront(centerButton)
    }
    
    private func positionCenterButton() {
        // Position the button in the center of the tab bar, raised higher
        let tabBarHeight = tabBar.frame.height
        let buttonSize: CGFloat = 60
        let yOffset: CGFloat = 25 // Increased offset to make it more prominent
        
        centerButton.frame = CGRect(
            x: view.bounds.width / 2 - buttonSize / 2,
            y: view.bounds.height - tabBarHeight - yOffset,
            width: buttonSize,
            height: buttonSize
        )
    }
    
    // MARK: - Actions
    @objc private func centerButtonTapped() {
        // Select the middle tab (index 2)
        selectedIndex = 2
    }
    
    // MARK: - Factory Method
    static func createTabBarController() -> TabBarController {
        return TabBarController()
    }
}

// MARK: - UITabBarControllerDelegate
extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
}
