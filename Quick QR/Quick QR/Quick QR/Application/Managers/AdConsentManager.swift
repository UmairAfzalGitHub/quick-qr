
import Foundation
import AppTrackingTransparency
import AdSupport
import UIKit
import GoogleMobileAds

class AdsConsentManager {
    
    static let shared = AdsConsentManager()
    
    private let gdprConsentKey = "GDPRConsentStatus"
    private init() {}
    
    // MARK: - Check ATT Consent
    func requestATTConsent(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized:
                        print("User authorized tracking")
                        completion(true)
                    case .denied, .restricted, .notDetermined:
                        print("ATT Not Authorized - Using Non-Personalized Ads")
                        let extras = Extras()
                        let request = Request()
                        extras.additionalParameters = ["npa": "1"]
                        request.register(extras)
                        completion(false)
                    @unknown default:
                        print("Unknown ATT status")
                        completion(false)
                    }
                }
            }
        }
    }
    
    // MARK: - Check GDPR Consent
    func checkGDPRConsent(completion: @escaping () -> Void) {
        // Example implementation, replace with your GDPR consent SDK logic
        if isUserInEEARegion() {
            // Show GDPR consent dialog or fetch consent status
            fetchGDPRConsentStatus {_ in
                completion()
            }
        } else {
            // GDPR not applicable
            completion()
        }
    }
    
    // MARK: - Utility Methods
    private func isUserInEEARegion() -> Bool {
        let eeaCountries = ["AF", "AT", "BE", "BG", "HR", "CY", "CZ", "DK", "EE", "FI", "FR", "DE", "GR", "HU", "IS", "IE", "IT", "LV", "LT", "LU", "MT", "NL", "NO", "PL", "PT", "RO", "SK", "SI", "ES", "SE", "GB"]
        let currentRegion = Locale.current.regionCode
        return eeaCountries.contains(currentRegion ?? "")
    }
    
    /// Check if GDPR applies based on the user's region
    private func isGDPRApplicable() -> Bool {
        return isUserInEEARegion()
    }
    
    /// Request GDPR consent (simulate showing a dialog to the user)
    private func requestConsent(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "GDPR Consent",
                message: "We value your privacy. Do you consent to personalized ads as per GDPR regulations?",
                preferredStyle: .alert
            )
            var completionCalled = false
            let callCompletionOnce: (Bool) -> Void = { consent in
                if !completionCalled {
                    completionCalled = true
                    completion(consent)
                }
            }
            alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { _ in
                callCompletionOnce(true)
            }))
            alert.addAction(UIAlertAction(title: "Decline", style: .cancel, handler: { _ in
                callCompletionOnce(false)
            }))
            // Handle dismiss (swipe/tap outside)
            class AlertDismissDelegateWrapper: NSObject, UIAdaptivePresentationControllerDelegate {
                let onDismiss: () -> Void
                init(onDismiss: @escaping () -> Void) { self.onDismiss = onDismiss }
                func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
                    onDismiss()
                }
            }
            let dismissDelegate = AlertDismissDelegateWrapper { callCompletionOnce(false) }
            alert.presentationController?.delegate = dismissDelegate
            // Retain the delegate for the duration of the alert
            objc_setAssociatedObject(alert, Unmanaged.passUnretained(alert).toOpaque(), dismissDelegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let topController = UIApplication.shared.topViewController {
                topController.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    /// Clear consent (useful for testing or resetting the app)
    func clearConsent() {
        UserDefaults.standard.removeObject(forKey: gdprConsentKey)
    }
    
    func fetchGDPRConsentStatus(completion: @escaping (Bool) -> Void) {
        if let consentStatus = UserDefaults.standard.value(forKey: gdprConsentKey) as? Bool {
            // Return previously saved consent status
            completion(consentStatus)
        } else if isGDPRApplicable() {
            // GDPR applies, request user consent
            requestConsent { consentGiven in
                UserDefaults.standard.setValue(consentGiven, forKey: self.gdprConsentKey)
                completion(consentGiven)
            }
        } else {
            // GDPR does not apply
            completion(true)
        }
    }
    
    // MARK: - Ads State Check
    func checkAdsState(completion: @escaping () -> Void) {
        requestATTConsent { isAuthorzed in
            if isAuthorzed {
                self.checkGDPRConsent {
                    completion()
                }
            } else {
                completion()
            }
        }
    }
}
