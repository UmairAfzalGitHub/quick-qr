
import UIKit
import Lottie
import IOS_Helpers
import GoogleMobileAds

class SplashViewController: BaseViewController, UITextViewDelegate {
        
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var progressBar: AnimatedProgressBar!
    @IBOutlet weak var bannerView: BannerView!
    @IBOutlet weak var bannerViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        hideCustomNavigationBar()
        IAPManager.shared.fetchSubscriptions()
        IAPManager.shared.checkSubscriptionStatus(completion: {[weak self] isSubscribed in
            guard let self else { return }
            
            if isSubscribed {
                // If subscribed, no need for ads consent
                self.animateForTwoSeconds()
                return
            }
            
            // Wait for ads consent before proceeding
            DispatchQueue.main.async {
                AdsConsentManager.shared.checkAdsState {
                    // Only setup ads and navigate after consent is handled
                    AdManager.shared.setupAds()                    
                    self.progressBar.animateIndeterminate(duration: 4.0, speed: 1.5) {
                        self.animateForTwoSeconds(preload: false)
                    }
                }
            }
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.setupBanner(adId: AdMobConfig.banner)
        super.bannerAdView = self.bannerView
        super.viewWillAppear(animated)
        
        IAPManager.shared.checkSubscriptionStatus { isSubscribed in
            self.bannerView.isHidden = isSubscribed
            self.bannerViewHeightConstraint.constant = isSubscribed ? 0 : 60
        }

        localize()
    }

    override func setup() {
        super.setup()
    }

    func localize() {
        // TODO: - Localize Here
        messageLabel.text = Strings.Label.scanInstantly
    }

    func checkLanguageStatus() {
        let onBoardingStatus = UserDefaults.standard.bool(forKey: "isOnboardingComplete")
        if onBoardingStatus {
            // Set maximum animation time to 4 seconds
            progressBar.animateIndeterminate(duration: 4.0, speed: 1.5) {}
            
            // Create a flag to track if we've already navigated
            var hasNavigated = false
            
            // Create a function to navigate to the TabBarController
            let navigateToTabBar = { (withAd: Bool) in
                // Prevent multiple navigation attempts
                guard !hasNavigated else { return }
                hasNavigated = true
                
                let nextController = TabBarController()
                
                // Set the default selected index based on whether the app is running on a simulator
                #if targetEnvironment(simulator)
                    nextController.selectedIndex = 0  // Create tab for simulator
                #else
                    nextController.selectedIndex = 2  // Scan tab for real device
                #endif
                
                if withAd && AdManager.shared.splashInterstitial {
                    AdManager.shared.adCounter = AdManager.shared.maxInterstitalAdCounter
                    AdManager.shared.showInterstitial(adId: AdMobConfig.interstitial) {
                        UIApplication.shared.updateRootViewController(to: nextController)
                    }
                } else {
                    // No ad to show, navigate directly
                    UIApplication.shared.updateRootViewController(to: nextController)
                }
            }
            
            // Set a timeout to ensure we don't wait more than 4 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                navigateToTabBar(false) // Navigate without ad if timeout occurs
            }
            
            // Try to load the ad
            AdManager.shared.loadInterstitialAd(id: AdMobConfig.interstitial) { isLoaded, interstitial in
                // If ad loaded successfully, show it and navigate
                navigateToTabBar(isLoaded ?? false)
            }
        } else {
            UIApplication.shared.updateRootViewController(to: LanguageSelectionViewController())
        }
    }
    
    func animateForTwoSeconds(preload: Bool = true) {
        let onBoardingStatus = UserDefaults.standard.bool(forKey: "isOnboardingComplete")
        if onBoardingStatus == false && preload {
            AdManager.shared.preloadNativeAds()
        }

        checkLanguageStatus()
    }
    
    @IBAction func didTapActionButton(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "isTermAccecpted")
        UserDefaults.standard.synchronize()
        self.checkLanguageStatus()
//        self.loadingAnimationView.stop() //This is important
    }
}
