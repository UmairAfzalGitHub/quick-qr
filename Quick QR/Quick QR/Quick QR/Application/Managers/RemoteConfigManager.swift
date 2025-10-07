
import Foundation
import FirebaseRemoteConfig

class RemoteConfigManager: NSObject {
    static let shared = RemoteConfigManager()
    private var remoteConfig: RemoteConfig!

    var appOpen = AdMobId(analyticsId: .appOpenAd, adId: "ca-app-pub-3940256099942544/5575463023")
    var interstitial = AdMobId(analyticsId: .interstitialAd, adId: "ca-app-pub-3940256099942544/4411468910")
    var native = AdMobId(analyticsId: .nativeAd, adId: "ca-app-pub-3940256099942544/3986624511")
    var floorNativeAd1 = AdMobId(analyticsId: .nativeAd, adId: "ca-app-pub-3940256099942544/3986624511")
    var floorNativeAd2 = AdMobId(analyticsId: .nativeAd, adId: "ca-app-pub-3940256099942544/3986624511")
    var rewarded = AdMobId(analyticsId: .rewardedAd, adId: "ca-app-pub-3940256099942544/1712485313")
    var banner = AdMobId(analyticsId: .bannerAd, adId: "ca-app-pub-3940256099942544/2934735716")
    var banner1 = AdMobId(analyticsId: .bannerAd, adId: "ca-app-pub-3940256099942544/2934735716")
    var banner2 = AdMobId(analyticsId: .bannerAd, adId: "ca-app-pub-3940256099942544/2934735716")

    var onboardingReviewEnabled = true
    var splashInterstitialEnabled = true
    var showInterstitalAfterOnboarding: Bool = false
    var showScannerNativeAtBottom: Bool = true
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
        let adCounter = remoteConfig["adcounter"].stringValue
        let adLoaderCounter = remoteConfig["adloadercounter"].stringValue
        let splashInterstitial = remoteConfig["is_splash_ad_enabled"].boolValue
        let onboardingReviewEnabled = remoteConfig["is_onboarding_review_enabled"].boolValue
        let variant = remoteConfig["iap_screen_varient"].stringValue
        let interstitialAfterOnboarding = remoteConfig["show_interstitial_after_onboarding"].boolValue
        let showNativeAtBottom = remoteConfig["show_scanner_native_at_bottom"].boolValue

        let appOpenId = remoteConfig["ad_id_app_open"].stringValue
        let interstitialId = remoteConfig["ad_id_interstitial"].stringValue
        let nativeId = remoteConfig["ad_id_native"].stringValue
        let floorNativeId1 = remoteConfig["ad_id_floor_native_1"].stringValue
        let floorNativeId2 = remoteConfig["ad_id_floor_native_2"].stringValue
        let bannerId = remoteConfig["ad_id_banner"].stringValue
        let bannerId1 = remoteConfig["ad_id_banner_1"].stringValue
        let bannerId2 = remoteConfig["ad_id_banner_2"].stringValue
        let rewardedId = remoteConfig["ad_id_rewarded"].stringValue
        
        self.iap_varient = variant
        self.maxInterstitalAdCounter = Int(adCounter) ?? 0
        self.adLoaderCounter = Int(adLoaderCounter) ?? 0
        self.splashInterstitialEnabled = splashInterstitial
        self.onboardingReviewEnabled = onboardingReviewEnabled
        self.showInterstitalAfterOnboarding = interstitialAfterOnboarding
        self.showScannerNativeAtBottom = showNativeAtBottom

        if getBuildEnv() == .appStore {
            self.appOpen = AdMobId(analyticsId: .appOpenAd, adId: appOpenId)
            self.interstitial = AdMobId(analyticsId: .interstitialAd, adId: interstitialId)
            self.native = AdMobId(analyticsId: .nativeAd, adId: nativeId)
            self.floorNativeAd1 = AdMobId(analyticsId: .nativeAd, adId: floorNativeId1)
            self.floorNativeAd2 = AdMobId(analyticsId: .nativeAd, adId: floorNativeId2)
            self.banner = AdMobId(analyticsId: .bannerAd, adId: bannerId)
            self.banner1 = AdMobId(analyticsId: .bannerAd, adId: bannerId1)
            self.banner2 = AdMobId(analyticsId: .bannerAd, adId: bannerId2)
            self.rewarded = AdMobId(analyticsId: .rewardedAd, adId: rewardedId)
        }
    }
}
