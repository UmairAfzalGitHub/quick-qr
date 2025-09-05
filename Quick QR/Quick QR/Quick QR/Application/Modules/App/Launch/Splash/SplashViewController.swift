
import UIKit
import Lottie
import IOS_Helpers
import GoogleMobileAds

class SplashViewController: BaseViewController, UITextViewDelegate {
        
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var progressBar: AnimatedProgressBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        hideCustomNavigationBar()
        IAPManager.shared.fetchSubscriptions()
        IAPManager.shared.checkSubscriptionStatus(completion: {[weak self] isSubscribed in
            guard let self, !isSubscribed else {
                self?.animateForTwoSeconds()
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                AdsConsentManager.shared.checkAdsState {
                    AdManager.shared.setupAds()
                    self.animateForTwoSeconds()
                }
            })
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.setupBanner(adId: AdMobConfig.banner)
        super.viewWillAppear(animated)
        localize()
    }

    override func setup() {
        super.setup()
    }

    func localize() {
        // TODO: - Localize Here
        messageLabel.text = Strings.Label.quickQR
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
            let controller = OnboardingViewController()
            let navController = UINavigationController(rootViewController: controller)
            navController.isNavigationBarHidden = true
            UIApplication.shared.updateRootViewController(to: navController)
        }
    }
    
    func animateForTwoSeconds() {
        let onBoardingStatus = UserDefaults.standard.bool(forKey: "isOnboardingComplete")
        if onBoardingStatus == false {
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
