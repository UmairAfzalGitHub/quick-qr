//
//  FeedbackMailer.swift
//  PhotoRecovery
//
//  Created by Haider on 10/12/2024.
//

import UIKit
import MessageUI

class FeedbackMailer: NSObject, MFMailComposeViewControllerDelegate {
    
    static let shared = FeedbackMailer() // Singleton for easy access
    
    private override init() {} // Prevent external instantiation
    
    func sendFeedback(from viewController: UIViewController) {
        // Check if the device can send emails
        guard MFMailComposeViewController.canSendMail() else {
            showMailErrorAlert(on: viewController)
            return
        }
        
        // Configure the mail composer
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients(["kineticsolutions.io@gmail.com"])
        mailComposeVC.setSubject("QR Code scanner")
        mailComposeVC.setMessageBody("Share your feedback here please.", isHTML: false)
        
        // Present the mail composer
        viewController.present(mailComposeVC, animated: true)
    }
    
    // Handle Mail Composer Dismissal
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
        
        if let error = error {
            print("Error sending email: \(error.localizedDescription)")
        } else {
            switch result {
            case .sent:
                print("Feedback email sent successfully!")
            case .cancelled:
                print("Feedback email cancelled.")
            case .saved:
                print("Feedback email saved as draft.")
            case .failed:
                print("Failed to send feedback email.")
            @unknown default:
                print("Unknown result for feedback email.")
            }
        }
    }
    
    // Helper: Show Error Alert if Mail Cannot Be Sent
    private func showMailErrorAlert(on viewController: UIViewController) {
        let alert = CustomAlertViewController(title: "Mail Not Configured", description: "Please configure your Mail app to send feedback.", alertType: .error)
        viewController.present(alert, animated: true)
    }
}
