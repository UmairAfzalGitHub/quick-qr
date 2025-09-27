//
//  LinkOpener.swift
//  PhotoRecovery
//
//  Created by Haider on 10/12/2024.
//

import UIKit

class LinkOpener {
    
    // Singleton instance
    static let shared = LinkOpener()
    
    private init() {} // Prevent external initialization
    
    /// Opens a URL in Safari
    /// - Parameters:
    ///   - urlString: The web URL string to open
    ///   - viewController: Optional view controller for presenting an error alert
    func openLink(_ urlString: String, from viewController: UIViewController?) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL string: \(urlString)")
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("Cannot open URL: \(urlString)")
            showErrorAlert(on: viewController)
        }
    }
    
    /// Shows an alert if the link cannot be opened
    private func showErrorAlert(on viewController: UIViewController?) {
        guard let vc = viewController else { return }
        let alert = UIAlertController(title: Strings.Label.error,
                                      message: "Unable to open link",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Strings.Messages.ok, style: .default))
        vc.present(alert, animated: true)
    }
}
