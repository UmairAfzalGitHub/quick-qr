//
//  UIViewController.swift
//  Photo Recovery
//
//  Created by Haider Rathore on 18/04/2025.
//

import UIKit

extension UIViewController {
    
    func presentShareSheet(with items: [Any], excludedActivityTypes: [UIActivity.ActivityType]? = nil) {
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        activityViewController.excludedActivityTypes = excludedActivityTypes
        
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX,
                                                  y: self.view.bounds.midY,
                                                  width: 0,
                                                  height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func showAlert(title: String,
                   message: String,
                   completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
            completion?()
        })
        self.present(alert, animated: true)
    }
    
    static func currentRootViewController() -> UIViewController? {
        guard let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        
        var rootVC = keyWindow.rootViewController
        
        // Traverse presented view controllers
        while let presentedVC = rootVC?.presentedViewController {
            rootVC = presentedVC
        }
        
        // Handle UINavigationController
        if let navController = rootVC as? UINavigationController {
            rootVC = navController.viewControllers.first
        }
        
        // Handle UITabBarController
        if let tabController = rootVC as? UITabBarController {
            rootVC = tabController.selectedViewController
        }
        
        return rootVC
    }
}
