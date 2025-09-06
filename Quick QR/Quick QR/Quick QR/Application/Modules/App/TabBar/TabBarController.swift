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
    private var shouldHideCenterButton = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupTabBarAppearance()
        setupCenterButton()
        setupNavigationControllerDelegates()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        positionCenterButton()
        
        // Ensure button stays on top after layout changes
        if !centerButton.isHidden && !shouldHideCenterButton {
            view.bringSubviewToFront(centerButton)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Ensure tab bar is visible
        tabBar.isHidden = false
        updateCenterButtonVisibility()
        
        // Always ensure center button is on top when view appears
        if !centerButton.isHidden {
            view.bringSubviewToFront(centerButton)
        }
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
        scanVC.title = "" // Empty title for center tab
        let scanNavController = UINavigationController(rootViewController: scanVC)
        
        let historyVC = HistoryViewController()
        historyVC.view.backgroundColor = .systemBackground
        historyVC.title = Strings.Label.history
        let historyNavController = UINavigationController(rootViewController: historyVC)

        let settingsVC = SettingsViewController()
        settingsVC.view.backgroundColor = .systemBackground
        settingsVC.title = Strings.Label.settings
        let settingsNavController = UINavigationController(rootViewController: settingsVC)

        // Configure tab bar items with larger images
        let createConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let favoriteConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let historyConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let settingsConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        
//        let createImage = UIImage(systemName: "plus.square", withConfiguration: createConfig)
//        let favoriteImage = UIImage(systemName: "heart", withConfiguration: favoriteConfig)
//        let historyImage = UIImage(systemName: "clock", withConfiguration: historyConfig)
//        let settingsImage = UIImage(systemName: "gear", withConfiguration: settingsConfig)
        
        let createImage   = UIImage(named: "create-tabbar-icon")?.withRenderingMode(.alwaysTemplate)
        let favoriteImage = UIImage(named: "heart-tabbar-icon")?.withRenderingMode(.alwaysTemplate)
        let historyImage  = UIImage(named: "history-tabbar-icon")?.withRenderingMode(.alwaysTemplate)
        let settingsImage = UIImage(named: "settings-tabbar-icon")?.withRenderingMode(.alwaysTemplate)
        
        let createItem = UITabBarItem(title: Strings.Label.create, image: createImage, tag: 0)
        let favoriteItem = UITabBarItem(title: Strings.Label.favorite, image: favoriteImage, tag: 1)
        // Center tab is invisible but takes up space
        let scanItem = UITabBarItem(title: "", image: UIImage(), tag: 2)
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
    
    private func setupCenterButton() {
        let scanImage = UIImage(named: "scan")
        centerButton.setImage(scanImage, for: .normal)
        centerButton.backgroundColor = .white
        centerButton.layer.cornerRadius = 30
        centerButton.layer.borderWidth = 2.0
        centerButton.layer.borderColor = UIColor.appPrimary.cgColor
        centerButton.addTarget(self, action: #selector(centerButtonTapped), for: .touchUpInside)
        
        // Add shadow
        centerButton.layer.shadowColor = UIColor.appPrimary.cgColor
        centerButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        centerButton.layer.shadowRadius = 8
        centerButton.layer.shadowOpacity = 0.4
        
        // Add button to view and ensure it's always on top
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
    
    // MARK: - Center Button Visibility
    private func updateCenterButtonVisibility() {
        // Hide center button when tab bar is hidden
        centerButton.isHidden = tabBar.isHidden || shouldHideCenterButton
        
        // Always ensure button is on top when visible
        if !centerButton.isHidden {
            view.bringSubviewToFront(centerButton)
            
            // Schedule another check to ensure it stays on top after any animations
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self = self, !self.centerButton.isHidden else { return }
                self.view.bringSubviewToFront(self.centerButton)
            }
            
            // And another slightly later to catch any delayed layout changes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let self = self, !self.centerButton.isHidden else { return }
                self.view.bringSubviewToFront(self.centerButton)
            }
        }
    }
    
    private func setupNavigationControllerDelegates() {
        // Set up delegates for each navigation controller
        viewControllers?.forEach { viewController in
            if let navController = viewController as? UINavigationController {
                navController.delegate = self
            }
        }
    }
}

// MARK: - UITabBarControllerDelegate
extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
}

// MARK: - UINavigationControllerDelegate
extension TabBarController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // Check if the view controller being pushed has hidesBottomBarWhenPushed set to true
        shouldHideCenterButton = viewController.hidesBottomBarWhenPushed
        updateCenterButtonVisibility()
        
        // Ensure button is in front when transitioning
        if !shouldHideCenterButton {
            DispatchQueue.main.async { [weak self] in
                self?.view.bringSubviewToFront(self?.centerButton ?? UIView())
            }
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // Update after the transition is complete
        shouldHideCenterButton = viewController.hidesBottomBarWhenPushed
        updateCenterButtonVisibility()
        
        // Ensure button is in front after transition completes
        if !shouldHideCenterButton {
            view.bringSubviewToFront(centerButton)
            
            // Add multiple delayed checks to ensure button stays on top
            // This handles cases where the tab bar's z-index might be updated after our initial check
            let checkTimes = [0.1, 0.2, 0.3, 0.5]
            for delay in checkTimes {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                    guard let self = self, !self.centerButton.isHidden, !self.shouldHideCenterButton else { return }
                    self.view.bringSubviewToFront(self.centerButton)
                }
            }
        }
    }
}
