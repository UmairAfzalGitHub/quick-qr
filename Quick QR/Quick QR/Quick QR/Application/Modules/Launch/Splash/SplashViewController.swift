
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
        messageLabel.text = Strings.Label.phoneNumberLocator
    }

    func checkLanguageStatus() {
        let onBoardingStatus = UserDefaults.standard.bool(forKey: "isOnboardingComplete")
        if onBoardingStatus {
            AdManager.shared.loadInterstitialAd(id: AdMobConfig.interstitial) { isLoaded, interstitial in
                let nextController = UINavigationController(rootViewController: HomeViewController())
                if AdManager.shared.splashInterstitial {
                    AdManager.shared.adCounter = AdManager.shared.maxInterstitalAdCounter
                }
                AdManager.shared.showInterstitial(adId: AdMobConfig.interstitial) {
                    UIApplication.shared.updateRootViewController(to: nextController)
                }
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

        progressBar.animateIndeterminate(duration: 4.0, speed: 1.5) {[weak self] in
            self?.checkLanguageStatus()
        }
    }
    
    @IBAction func didTapActionButton(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "isTermAccecpted")
        UserDefaults.standard.synchronize()
        self.checkLanguageStatus()
//        self.loadingAnimationView.stop() //This is important
    }
}
