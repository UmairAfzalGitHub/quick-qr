
import Foundation
import FirebaseRemoteConfig

class RemoteConfigManager: NSObject {
    static let shared = RemoteConfigManager()
    private var remoteConfig: RemoteConfig!

    var appOpen = AdMobId(analyticsId: .appOpenAd, adId: "ca-app-pub-3940256099942544/5575463023")
    var interstitial = AdMobId(analyticsId: .interstitialAd, adId: "ca-app-pub-3940256099942544/4411468910")
    var native = AdMobId(analyticsId: .nativeAd, adId: "ca-app-pub-3940256099942544/3986624511")
    var banner = AdMobId(analyticsId: .bannerAd, adId: "ca-app-pub-3940256099942544/2934735716")
    var rewarded = AdMobId(analyticsId: .rewardedAd, adId: "ca-app-pub-3940256099942544/1712485313")

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

        let appOpenId = remoteConfig["AppOpenId"].stringValue
        let interstitialId = remoteConfig["AppOpenId"].stringValue
        let nativeId = remoteConfig["AppOpenId"].stringValue
        let bannerId = remoteConfig["AppOpenId"].stringValue
        let rewardedId = remoteConfig["AppOpenId"].stringValue

        self.iap_varient = variant
        print("iap_varient", self.iap_varient ?? "--")
        self.maxInterstitalAdCounter = Int(adCounter) ?? 0
        self.adLoaderCounter = Int(adLoaderCounter) ?? 0
        self.splashInterstitialEnabled = splashInterstitial
        self.onboardingReviewEnabled = onboardingReviewEnabled
        
#if !DEBUG
        self.appOpen = AdMobId(analyticsId: .appOpenAd, adId: appOpenId)
        self.interstitial = AdMobId(analyticsId: .interstitialAd, adId: interstitialId)
        self.native = AdMobId(analyticsId: .nativeAd, adId: nativeId)
        self.banner = AdMobId(analyticsId: .bannerAd, adId: bannerId)
        self.rewarded = AdMobId(analyticsId: .rewardedAd, adId: rewardedId)
#endif

    }
}
