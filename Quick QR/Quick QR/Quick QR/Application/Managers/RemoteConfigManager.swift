
import Foundation
import FirebaseRemoteConfig

// MARK: - Ad Config Models
struct AdConfig: Codable {
    let status: Bool
    let id: String
}

struct RemoteConfigData: Codable {
    let appOpen: AdConfig?
    let interstitial: AdConfig?
    let highECPMInterstitial: AdConfig?
    let native: AdConfig?
    let floorNative1: AdConfig?
    let floorNative2: AdConfig?
    let rewarded: AdConfig?
    let banner: AdConfig?
    let banner1: AdConfig?
    let banner2: AdConfig?
    let splashInterstitial: AdConfig?
    
    // Non-ad configs
    let adCounter: Int?
    let adLoaderCounter: Int?
    let onboardingReviewEnabled: Bool?
    let showInterstitialAfterOnboarding: Bool?
    let showScannerNativeAtBottom: Bool?
    let iapScreenVariant: String?
    
    enum CodingKeys: String, CodingKey {
        case appOpen = "app_open"
        case interstitial = "interstitial"
        case highECPMInterstitial = "high_ecpm_interstitial"
        case native = "native"
        case floorNative1 = "floor_native_1"
        case floorNative2 = "floor_native_2"
        case rewarded = "rewarded"
        case banner = "banner"
        case banner1 = "banner_1"
        case banner2 = "banner_2"
        case splashInterstitial = "splash_interstitial"
        case adCounter = "ad_counter"
        case adLoaderCounter = "ad_loader_counter"
        case onboardingReviewEnabled = "onboarding_review_enabled"
        case showInterstitialAfterOnboarding = "show_interstitial_after_onboarding"
        case showScannerNativeAtBottom = "show_scanner_native_at_bottom"
        case iapScreenVariant = "iap_screen_variant"
    }
}

class RemoteConfigManager: NSObject {
    static let shared = RemoteConfigManager()
    private var remoteConfig: RemoteConfig!

    var appOpen = AdMobId(analyticsId: .appOpenAd, adId: "ca-app-pub-3940256099942544/5575463023")
    var interstitial = AdMobId(analyticsId: .interstitialAd, adId: "ca-app-pub-3940256099942544/4411468910")
    var highECPMinterstitial = AdMobId(analyticsId: .interstitialAd, adId: "ca-app-pub-3940256099942544/4411468910")
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
        let jsonString = remoteConfig["ad_config"].stringValue
        
        guard !jsonString.isEmpty,
              let jsonData = jsonString.data(using: .utf8) else {
            print("⚠️ Remote Config JSON is empty or invalid, using default values")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let config = try decoder.decode(RemoteConfigData.self, from: jsonData)
            
            // Update non-ad properties with nil coalescing
            self.iap_varient = config.iapScreenVariant ?? "A"
            self.maxInterstitalAdCounter = config.adCounter ?? self.maxInterstitalAdCounter
            self.adLoaderCounter = config.adLoaderCounter ?? self.adLoaderCounter
            self.splashInterstitialEnabled = config.splashInterstitial?.status ?? self.splashInterstitialEnabled
            self.onboardingReviewEnabled = config.onboardingReviewEnabled ?? self.onboardingReviewEnabled
            self.showInterstitalAfterOnboarding = config.showInterstitialAfterOnboarding ?? self.showInterstitalAfterOnboarding
            self.showScannerNativeAtBottom = config.showScannerNativeAtBottom ?? self.showScannerNativeAtBottom
            
            // Update ad IDs only for AppStore builds
            if getBuildEnv() == .appStore {
                if let appOpen = config.appOpen {
                    self.appOpen = AdMobId(analyticsId: .appOpenAd, adId: appOpen.status ? appOpen.id : "")
                }
                if let interstitial = config.interstitial {
                    self.interstitial = AdMobId(analyticsId: .interstitialAd, adId: interstitial.status ? interstitial.id : "")
                }
                if let highECPM = config.highECPMInterstitial {
                    self.highECPMinterstitial = AdMobId(analyticsId: .interstitialAd, adId: highECPM.status ? highECPM.id : "")
                }
                if let native = config.native {
                    self.native = AdMobId(analyticsId: .nativeAd, adId: native.status ? native.id : "")
                }
                if let floorNative1 = config.floorNative1 {
                    self.floorNativeAd1 = AdMobId(analyticsId: .nativeAd, adId: floorNative1.status ? floorNative1.id : "")
                }
                if let floorNative2 = config.floorNative2 {
                    self.floorNativeAd2 = AdMobId(analyticsId: .nativeAd, adId: floorNative2.status ? floorNative2.id : "")
                }
                if let rewarded = config.rewarded {
                    self.rewarded = AdMobId(analyticsId: .rewardedAd, adId: rewarded.status ? rewarded.id : "")
                }
                if let banner = config.banner {
                    self.banner = AdMobId(analyticsId: .bannerAd, adId: banner.status ? banner.id : "")
                }
                if let banner1 = config.banner1 {
                    self.banner1 = AdMobId(analyticsId: .bannerAd, adId: banner1.status ? banner1.id : "")
                }
                if let banner2 = config.banner2 {
                    self.banner2 = AdMobId(analyticsId: .bannerAd, adId: banner2.status ? banner2.id : "")
                }
            }
            
            print("✅ Remote Config loaded successfully")
            print("📊 Ad Counter: \(self.maxInterstitalAdCounter)")
            print("📊 Splash Interstitial: \(self.splashInterstitialEnabled)")
            
        } catch {
            print("❌ Failed to decode Remote Config JSON: \(error.localizedDescription)")
            print("📄 JSON String: \(jsonString)")
        }
    }
}
