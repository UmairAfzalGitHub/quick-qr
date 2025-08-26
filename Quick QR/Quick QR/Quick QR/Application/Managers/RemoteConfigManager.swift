//
//  RemoteConfigManager.swift
//  Photo Recovery
//
//  Created by Umair Afzal on 27/05/2025.
//

import Foundation
import FirebaseRemoteConfig

class RemoteConfigManager: NSObject {
    static let shared = RemoteConfigManager()
    private var remoteConfig: RemoteConfig!

    var onboardingReviewEnabled = true
    var splashInterstitialEnabled = true
    var adLoaderCounter = 1
    var iap_varient: String = "A"
    var maxInterstitalAdCounter: Int = {
#if DEBUG
        return 22
#else
        return 1
#endif
    }()
    
    private override init() {
        remoteConfig = RemoteConfig.remoteConfig()
    }
    
    func fetchAdmobConfig() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3600 // Fetch every hour
        remoteConfig.configSettings = settings

        remoteConfig.fetch { [weak self] (status, error) in
            if status == .success {
                self?.remoteConfig.activate { _, _ in
                    self?.storeID()
                }
            } else {
                print("❌ Remote Config fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    private func storeID() {
        let adCounter = remoteConfig["ad_counter"].stringValue
        let adLoaderCounter = remoteConfig["ad_loader_counter"].stringValue
        let splashInterstitial = remoteConfig["is_splash_ad_enabled"].boolValue
        let onboardingReviewEnabled = remoteConfig["is_onboarding_review_enabled"].boolValue
        let variant = remoteConfig["iap_screen_varient"].stringValue

        self.iap_varient = variant
        print("iap_varient", self.iap_varient ?? "--")
        self.maxInterstitalAdCounter = Int(adCounter) ?? 0
        self.adLoaderCounter = Int(adLoaderCounter) ?? 0
        self.splashInterstitialEnabled = splashInterstitial
        self.onboardingReviewEnabled = onboardingReviewEnabled
    }
}
