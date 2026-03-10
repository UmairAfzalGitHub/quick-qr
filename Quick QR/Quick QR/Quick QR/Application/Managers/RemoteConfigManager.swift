
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

#if DEBUG
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
#else
    var appOpen = AdMobId(analyticsId: .appOpenAd, adId: "ca-app-pub-7197936742422632/6331007920")
    var interstitial = AdMobId(analyticsId: .interstitialAd, adId: "ca-app-pub-7197936742422632/9679225995")
    var highECPMinterstitial = AdMobId(analyticsId: .interstitialAd, adId: "ca-app-pub-7197936742422632/9679225995")
    var native = AdMobId(analyticsId: .nativeAd, adId: "ca-app-pub-7197936742422632/8623157019")
    var floorNativeAd1 = AdMobId(analyticsId: .nativeAd, adId: "ca-app-pub-7197936742422632/8623157019")
    var floorNativeAd2 = AdMobId(analyticsId: .nativeAd, adId: "ca-app-pub-7197936742422632/8623157019")
    var rewarded = AdMobId(analyticsId: .rewardedAd, adId: "ca-app-pub-7197936742422632/7571937404")
    var banner = AdMobId(analyticsId: .bannerAd, adId: "ca-app-pub-7197936742422632/8957171267")
    var banner1 = AdMobId(analyticsId: .bannerAd, adId: "ca-app-pub-7197936742422632/8957171267")
    var banner2 = AdMobId(analyticsId: .bannerAd, adId: "ca-app-pub-7197936742422632/8957171267")
#endif

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
              let jsonData = jsonString.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            print("⚠️ Remote Config JSON is empty or invalid, using default values")
            return
        }
        
        // Helper to parse bools safely
        func getBool(_ key: String, from dict: [String: Any]) -> Bool? {
            if let b = dict[key] as? Bool { return b }
            if let i = dict[key] as? Int { return i == 1 }
            if let s = dict[key] as? String { return s.lowercased() == "true" || s == "1" }
            return nil
        }
        
        // Helper to parse ints safely
        func getInt(_ key: String, from dict: [String: Any]) -> Int? {
            if let i = dict[key] as? Int { return i }
            if let s = dict[key] as? String { return Int(s) }
            return nil
        }
        
        // Helper to parse ad config safely
        func getAdConfig(_ key: String, from dict: [String: Any]) -> (status: Bool, id: String)? {
            guard let adDict = dict[key] as? [String: Any] else { return nil }
            let status = getBool("status", from: adDict) ?? false
            let id = (adDict["id"] as? String) ?? ""
            return (status, id)
        }
        
        // Update non-ad properties
        self.iap_varient = (dict["iap_screen_variant"] as? String) ?? "A"
        self.maxInterstitalAdCounter = getInt("ad_counter", from: dict) ?? self.maxInterstitalAdCounter
        self.adLoaderCounter = getInt("ad_loader_counter", from: dict) ?? self.adLoaderCounter
        
        if let splashDict = dict["splash_interstitial"] as? [String: Any] {
            self.splashInterstitialEnabled = getBool("status", from: splashDict) ?? self.splashInterstitialEnabled
        }
        
        self.onboardingReviewEnabled = getBool("onboarding_review_enabled", from: dict) ?? self.onboardingReviewEnabled
        self.showInterstitalAfterOnboarding = getBool("show_interstitial_after_onboarding", from: dict) ?? self.showInterstitalAfterOnboarding
        self.showScannerNativeAtBottom = getBool("show_scanner_native_at_bottom", from: dict) ?? self.showScannerNativeAtBottom
        
        print("✅ Remote Config loaded successfully (Ad IDs Hardcoded)")
        print("📊 Ad Counter: \(self.maxInterstitalAdCounter)")
        print("📊 Splash Interstitial: \(self.splashInterstitialEnabled)")
    }
}
