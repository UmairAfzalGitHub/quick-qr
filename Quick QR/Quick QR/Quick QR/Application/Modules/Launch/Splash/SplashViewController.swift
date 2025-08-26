
import UIKit
import Lottie
import IOS_Helpers

class SplashViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var linksTextView: UITextView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var actionButton: AppButton!
    @IBOutlet weak var loadingAnimationView: LottieAnimationView!
    
    var reviewEnabled: Bool?
    var splashAdEnabled: Bool?
    var onBoardingStatus: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        IAPManager.shared.fetchSubscriptions()
        
        // Check subscription status using the property
        if IAPManager.shared.isUserSubscribed {
            checkTermsAndConditions()
            setupLinksTextView()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
                guard let self = self else { return }
                AdsConsentManager.shared.checkAdsState {
                    AdManager.shared.setupAds()
                    self.checkTermsAndConditions()
                    self.setupLinksTextView()
                }
            })
        }
    }
    
    func setup() {
        loadingAnimationView.loopMode = .loop
        loadingAnimationView.animationSpeed = 1
        loadingAnimationView.play()
        
        actionButton.setTitle("Agree & Continue", for: .normal)
        actionButton.setupButton(type: .primary)
        actionButton.layer.cornerRadius = 8
    }
    
    func checkOnboardingStatus() {
        UIApplication.shared.updateRootViewController(to: HomeViewContoller())
        return  // remove this and above line in actual app
        
        // Uncomment this in actual app
//        splashAdEnabled = RemoteConfigManager.shared.splashInterstitialEnabled
//        reviewEnabled = RemoteConfigManager.shared.onboardingReviewEnabled
//        onBoardingStatus = UserDefaultManager.shared.getValue(.onBoarding(false)) as? Bool ?? false
//        
//        if splashAdEnabled ?? true {
//            AdManager.shared.loadInterstitialAd(id: AdMobConfig.interstitial) { isLoaded, interstitial in
//                self.startSplash()
//            }
//        } else {
//            self.startSplash()
//        }
    }
    
    func startSplash() {
        
        // If onboarding is not complete and review is enabled, show onboarding first
        if !(self.onBoardingStatus ?? true) && self.reviewEnabled ?? false {
            UIApplication.shared.updateRootViewController(to: OnboardingViewController())
            return
        }
        
        let nextController = HomeViewContoller()
        if RemoteConfigManager.shared.splashInterstitialEnabled {
            AdManager.shared.adCounter = RemoteConfigManager.shared.maxInterstitalAdCounter
        }
        AdManager.shared.showInterstitial(adId: AdMobConfig.interstitial) {
            UIApplication.shared.updateRootViewController(to: nextController)
        }
        return
    }
    
    func checkTermsAndConditions() {
        let termsStatus = UserDefaultManager.shared.getValue(.termsAccepted(false)) as? Bool ?? false
        if termsStatus {
            loadingAnimationView.isHidden = false
            bottomStackView.isHidden = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { //Custom Wait
                self.checkOnboardingStatus()
            })
        } else {
            loadingAnimationView.isHidden = true
            bottomStackView.isHidden = false
        }
    }
    
    @IBAction func didTapActionButton(_ sender: Any) {
        UserDefaultManager.shared.setValue(.termsAccepted(true))
        self.checkOnboardingStatus()
        self.loadingAnimationView.stop() //This is important
    }
    
    private func setupLinksTextView() {
        linksTextView.backgroundColor = .clear
        linksTextView.textAlignment = .center
        linksTextView.isEditable = false
        linksTextView.isScrollEnabled = false
        linksTextView.textAlignment = .center
        linksTextView.font = UIFont.systemFont(ofSize: 13.0) // Default font for UITextView
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let fullText = "Privacy For further information, please check our Privacy Policy and Terms & Conditions."
        let attributedString = NSMutableAttributedString(string: fullText, attributes: [
            .foregroundColor: UIColor.textPrimary,
            .font: UIFont.systemFont(ofSize: 13.0),
            .paragraphStyle: paragraphStyle // Apply font to the whole text
        ])
        
        // Add links
        let privacyPolicyRange = (fullText as NSString).range(of: "Privacy Policy")
        let termsAndConditionsRange = (fullText as NSString).range(of: "Terms & Conditions")
        
        attributedString.addAttributes([
            .link: URL(string: "https://doc-hosting.flycricket.io/photo-recovery-videos-recovery-privacy-policy/b1727af7-f37a-4686-b37d-f925a1e26218/privacy")!,
            .font: UIFont.systemFont(ofSize: 13.0), // Apply link-specific font
            .foregroundColor: UIColor.appGreenMedium
        ], range: privacyPolicyRange)
        
        attributedString.addAttributes([
            .link: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!,
            .font: UIFont.systemFont(ofSize: 13.0), // Apply link-specific font
            .foregroundColor: UIColor.appGreenMedium
        ], range: termsAndConditionsRange)
        
        linksTextView.attributedText = attributedString
        linksTextView.delegate = self
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        openURL(URL.absoluteString)
        return false // Prevent default behavior
    }
    
    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}
