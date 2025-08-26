//
//  AdManager.swift
//  Phone Number Tracker
//
//  Created by Umair Afzal on 06/03/2025.
//

import Foundation
import Foundation
import GoogleMobileAds
import UIKit
import StoreKit
import FirebaseAnalytics
import IOS_Helpers

// MARK: - Ad Configuration

enum AdTypes: String {
    case appOpenAd = "appOpen_ad"
    case interstitialAd = "interstitial_ad"
    case nativeAd = "native_ad"
    case bannerAd = "banner_ad"
    case rewardedAd = "rewarded_ad"
}

struct AdMobId {
    var analyticsId: AdTypes
    var adId: String
}

struct AdMobConfig {
#if DEBUG // Test
    static var appOpen = AdMobId(analyticsId: .appOpenAd, adId: "ca-app-pub-3940256099942544/5575463023")
    static var interstitial = AdMobId(analyticsId: .interstitialAd, adId: "ca-app-pub-3940256099942544/4411468910")
    static var native = AdMobId(analyticsId: .nativeAd, adId: "ca-app-pub-3940256099942544/3986624511")
    static var banner = AdMobId(analyticsId: .bannerAd, adId: "ca-app-pub-3940256099942544/2934735716")
    static var rewarded = AdMobId(analyticsId: .rewardedAd, adId: "ca-app-pub-3940256099942544/1712485313")
#else // Live
    static var appOpen = AdMobId(analyticsId: .appOpenAd, adId: "ca-app-pub-7197936742422632/1164898117")
    static var interstitial = AdMobId(analyticsId: .interstitialAd, adId: "ca-app-pub-7197936742422632/6898502720")
    static var native = AdMobId(analyticsId: .nativeAd, adId: "ca-app-pub-7197936742422632/4272339384")
    static var banner = AdMobId(analyticsId: .bannerAd, adId: "ca-app-pub-7197936742422632/5810720131")
    static var rewarded = AdMobId(analyticsId: .rewardedAd, adId: "ca-app-pub-7197936742422632/5585421050")
#endif
}

// MARK: - Ad Manager
class AdManager: NSObject, AdLoaderDelegate, NativeAdLoaderDelegate {
    static let shared = AdManager()
    
    // Ad Properties
    var appOpenAd: AppOpenAd?
    var interstitialAd: InterstitialAd?
    var rewardedAd: RewardedAd?
    private var nativeAdLoader: AdLoader?
    
    // State Management
    private var isLoadingAppOpenAd = false
    private var isLoadingInterstitial = false
    private var isLoadingRewarded = false
    private var adDidDismissFullScreenContentCallback: (() -> Void)?
    private var adDidDismissRewardedCallback: ((Bool) -> Void)?
    private var didGetNativeAd: ((NativeAd?) -> Void)?
    
    var isRewardGranted = false
    var avilableNativeAd: NativeAd?
    var isShowingAd = false
    var adCounter = 0
    var adLoaderCounter = 1
    var splashInterstitial = true
    var onboardingReviewEnabled = false
    var maxInterstitalAdCounter: Int = {
#if DEBUG
        return 2
#else
        return 1
#endif
    }()
    
    private override init() {
        super.init()
    }
    
    // MARK: - Setup
    func setupAds() {
        print("📱 Setting up AdMob...")
        //        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ GADSimulatorID ]
        
        MobileAds.shared.start { [weak self] status in
            print("📱 AdMob SDK initialization completed with status: \(status)")
            self?.loadAppOpenAd()
//            self?.loadRewardedAd(id: AdMobConfig.rewarded)
        }
    }
    
    func isUserSubscribed() async -> Bool {
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                if transaction.productType == .autoRenewable {
                    return true
                }
            case .unverified:
                continue
            }
        }
        return false
    }
    
    func checkSubscriptionAndSave() async {
        let subscribed = await isUserSubscribed()
        UserDefaults.standard.set(subscribed, forKey: "isUserSubscribed")
    }
    
    private func loadAllAds() {
        print("📱 Starting to load all ads")
        guard !UserDefaults.standard.bool(forKey: "isUserSubscribed") else { return }
    }
    
    // MARK: - App Open Ads
    
    func incrementAdCounter() {
        guard !UserDefaults.standard.bool(forKey: "isUserSubscribed") else { return }

        adCounter += 1
        print("AdCounter: \(adCounter)")
        if adCounter ==  maxInterstitalAdCounter-adLoaderCounter {
             loadInterstitialAd(id: AdMobConfig.interstitial)
         }
     }
    
    func loadAppOpenAd() {
        IAPManager.shared.checkSubscriptionStatus(completion: {[weak self] isSubscribed in
            guard let self, !isSubscribed else { return }
            guard !isLoadingAppOpenAd else { return }
            isLoadingAppOpenAd = true
            
            AppOpenAd.load(with: AdMobConfig.appOpen.adId,
                           request: Request()) { [weak self] ad, error in
                guard let self = self else { return }
                self.isLoadingAppOpenAd = false
                
                if let error = error {
                    print("❌ Failed to load app open ad: \(error.localizedDescription)")
                    return
                }
                print("✅ App Open ad loaded successfully")
                self.appOpenAd = ad
            }
        })
    }
    
    func showAppOpenAd() {
        IAPManager.shared.checkSubscriptionStatus(completion: {[weak self] isSubscribed in
            guard let self, !isSubscribed else { return }
            guard let appOpenAd = self.appOpenAd, !self.isShowingAd else { return }
            guard shouldShowAd() else { return }
            
            appOpenAd.fullScreenContentDelegate = self
            appOpenAd.present(from: UIApplication.shared.topViewController!)
            self.isShowingAd = true
            print("▶️ App Open Ad shown successfully")
            self.loadAppOpenAd() // Preload next ad
        })
    }
    
    func shouldShowAd() -> Bool {
        let defaults = UserDefaults.standard
        let currentTime = Date().timeIntervalSince1970 // Get current time in seconds
        
        // Retrieve last ad time
        let lastAdTime = defaults.double(forKey: "LastAdTime")
        
        // If lastAdTime is 0, it means no ad was shown before, so show the ad
        if lastAdTime > 0 {
            let timeSinceLastAd = currentTime - lastAdTime
            
            print("timeSinceLastAd: \(timeSinceLastAd)")
            // Check if 5 seconds have passed since the last ad
            if timeSinceLastAd < 5 {
                print("Ad was shown \(timeSinceLastAd) seconds ago. Not showing ad.")
                return false
            }
        }
        
        // Save current time as last ad shown time
        defaults.set(currentTime, forKey: "LastAdTime")
        
        print("Showing ad now.")
        return true
    }
    
    // MARK: - Interstitial Ads
    func loadInterstitialAd(id: AdMobId, completion: ((Bool?, InterstitialAd?) -> Void)? = nil) {
        IAPManager.shared.checkSubscriptionStatus(completion: {[weak self] isSubscribed in
            guard let self, !isSubscribed, !isLoadingInterstitial else {
                completion?(nil, nil)
                return
            }
            isLoadingInterstitial = true
            print("📱 Loading Interstitial Ad...")
            
            InterstitialAd.load(with: id.adId,
                                request: Request()) { [weak self] ad, error in
                guard let self = self else { return }
                self.isLoadingInterstitial = false
                
                if let error = error {
                    print("❌ Failed to load interstitial ad: \(error.localizedDescription)")
                    completion?(false, nil)
                    return
                }
                print("✅ Interstitial ad loaded successfully")
                self.interstitialAd = ad
                self.interstitialAd?.fullScreenContentDelegate = self
                completion?(true, ad)
            }
        })
    }
    
    func showInterstitial(adId: AdMobId, from viewController: UIViewController? = nil, completion: (() -> Void)? = nil) {
        incrementAdCounter()

        guard let interstitialAd = interstitialAd else {
            print("❌ Interstitial Ad is not available")
            completion?()
            return
        }
        
        guard !isShowingAd else {
            print("❌ Interstitial Ad cannot be shown because an ad is already being displayed")
            completion?()
            return
        }
        
        guard adCounter >= maxInterstitalAdCounter else {
            completion?()
            return
        }
        
        // analytics
        Analytics.logEvent("ad_"+adId.analyticsId.rawValue, parameters: nil)
        
        interstitialAd.fullScreenContentDelegate = self
        interstitialAd.present(from: viewController)
        isShowingAd = true
        adCounter = 0
        print("▶️ Interstitial Ad shown successfully")
        
        // Call the completion block after the ad is dismissed
        adDidDismissFullScreenContentCallback = completion
    }
    
    // MARK: - Rewarded Ads
    func loadRewardedAd(id: AdMobId, completion: ((Bool?) -> Void)? = nil) {
        IAPManager.shared.checkSubscriptionStatus(completion: {[weak self] isSubscribed in
            guard let self, !isSubscribed, !isLoadingRewarded else {
                completion?(nil)
                return
            }
            isLoadingRewarded = true
            print("📱 Loading Rewarded Ad...")
            
            RewardedAd.load(with: id.adId,
                            request: Request()) { [weak self] ad, error in
                guard let self = self else { return }
                self.isLoadingRewarded = false
                
                if let error = error {
                    print("❌ Failed to load rewarded ad: \(error.localizedDescription)")
                    completion?(false)
                    return
                }
                print("✅ Rewarded ad loaded successfully")
                self.rewardedAd = ad
                completion?(true)
            }
        })
    }
    
    func showRewardedAd(adId: AdMobId, from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        guard let rewardedAd = rewardedAd else {
            print("❌ Rewarded Ad is not available")
            completion(false)
            return
        }
        
        guard !isShowingAd else {
            print("❌ Rewarded Ad cannot be shown because an ad is already being displayed")
            completion(false)
            return
        }
        
        // analytics
        Analytics.logEvent("ad_"+adId.analyticsId.rawValue, parameters: nil)
        
        self.adDidDismissRewardedCallback = completion
        rewardedAd.fullScreenContentDelegate = self
        rewardedAd.present(from: viewController) { [weak self] in
            self?.isRewardGranted = true
        }
        isShowingAd = true
        print("▶️ Rewarded Ad shown successfully")
    }
    
    // MARK: - Banner Ads
    
    func loadbannerAd(adId: AdMobId, bannerView: BannerView?, root: UIViewController) {
        IAPManager.shared.checkSubscriptionStatus(completion: {isSubscribed in
            guard !isSubscribed else { return }
            bannerView?.adUnitID = adId.adId
            bannerView?.rootViewController = root
            bannerView?.load(Request())
            // analytics
            Analytics.logEvent("ad_"+adId.analyticsId.rawValue, parameters: nil)
        })
    }
    
    // MARK: - Native Ads
    func loadNativeAd(adId: AdMobId, from viewController: UIViewController,
                      completion: ((GoogleMobileAds.NativeAd?) -> Void)?) {
        print("📱 Attempting to load Native Ad...")
        IAPManager.shared.checkSubscriptionStatus(completion: {[weak self] isSubscribed in
            guard let self, !isSubscribed else {
                completion?(nil)
                return
            }
            
            // Attempt to load Google Native Ad first
            let googleAdLoader = GoogleMobileAds.AdLoader(adUnitID: adId.adId,
                                                          rootViewController: viewController,
                                                          adTypes: [.native],
                                                          options: nil)
            
            googleAdLoader.delegate = self
            googleAdLoader.load(Request())
            self.nativeAdLoader = googleAdLoader
            self.didGetNativeAd = { googleNativeAd in
                if let googleNativeAd = googleNativeAd {
                    print("✅ Google Native Ad loaded successfully")
                } else {
                    print("❌ Failed to load Google Native Ad")
                }
                
                completion?(googleNativeAd)
            }
            print("📱 Google Native Ad load request sent")
        })
    }
}

// MARK: - GADFullScreenContentDelegate
extension AdManager: FullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        isShowingAd = false

        // Ensure we have ads ready for next time
        interstitialAd = nil
        rewardedAd = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.adDidDismissFullScreenContentCallback?()
            self.adDidDismissRewardedCallback?(self.isRewardGranted)
            
            self.adDidDismissFullScreenContentCallback = nil
            self.adDidDismissRewardedCallback = nil
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
            self.isRewardGranted = false
        })
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        isShowingAd = false
        print("❌ Failed to present ad: \(error.localizedDescription)")
    }
    
    // MARK: - NativeAdLoaderDelegate
    
    func adLoader(_ adLoader: GoogleMobileAds.AdLoader, didReceive nativeAd: GoogleMobileAds.NativeAd) {
        print("✅ Native Ad loaded successfully")
        avilableNativeAd = nativeAd
        didGetNativeAd?(nativeAd)
    }
    
    func adLoader(_ adLoader: GoogleMobileAds.AdLoader, didFailToReceiveAdWithError error: Error) {
        print("❌ Failed to load Native Ad: \(error.localizedDescription)")
        didGetNativeAd?(nil)
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GoogleMobileAds.AdLoader) {
        print("ℹ️ AdLoader finished loading.")
    }
    
    func adDidRecordImpression(_ ad: any GoogleMobileAds.FullScreenPresentingAd) {
        Analytics.logEvent("custom_ad_impression", parameters: nil)
    }
}
