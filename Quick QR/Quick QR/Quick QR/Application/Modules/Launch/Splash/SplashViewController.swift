
import UIKit
import Lottie
import IOS_Helpers
import GoogleMobileAds

class SplashViewController: BaseViewController, UITextViewDelegate {
    
    @IBOutlet weak var bannerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var loadingAnimationView: LottieAnimationView!
    @IBOutlet weak var appTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        hideCustomNavigationBar()
        IAPManager.shared.fetchSubscriptions()
        IAPManager.shared.checkSubscriptionStatus(completion: {[weak self] isSubscribed in
            self?.bannerViewHeightConstraint.constant = isSubscribed ? 0 : 60
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
        loadingAnimationView.loopMode = .loop
        loadingAnimationView.animationSpeed = 0.65
        loadingAnimationView.play()
    }

    func localize() {
        appTitleLabel.text = Strings.Label.phoneNumberLocator
    }

    func checkLanguageStatus() {
        let onBoardingStatus = UserDefaults.standard.bool(forKey: "isOnboardingComplete")
        if onBoardingStatus {
            AdManager.shared.loadInterstitialAd(id: AdMobConfig.interstitial) { isLoaded, interstitial in
//                let nextController = UINavigationController(rootViewController: HomeViewController())
//                nextController.isNavigationBarHidden = true
//                if AdManager.shared.splashInterstitial {
//                    AdManager.shared.adCounter = AdManager.shared.maxInterstitalAdCounter
//                }
//                AdManager.shared.showInterstitial(adId: AdMobConfig.interstitial) {
//                    UIApplication.shared.updateRootViewController(to: nextController)
//                }
            }
        } else {
            AdManager.shared.loadNativeAd(adId: AdMobConfig.native,
                                          from: self) { nativeAd in
//                let controller = LanguageViewController(viewMode: .main,
//                                                        intent: .onboarding,
//                                                        nativeAd: nativeAd)
//                let navController = UINavigationController(rootViewController: controller)
//                UIApplication.shared.updateRootViewController(to: navController)
            }
        }
    }
    
    func animateForTwoSeconds() {
        loadingAnimationView.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            self.checkLanguageStatus()
        })
    }
    
    @IBAction func didTapActionButton(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "isTermAccecpted")
        UserDefaults.standard.synchronize()
        self.checkLanguageStatus()
        self.loadingAnimationView.stop() //This is important
    }
}
