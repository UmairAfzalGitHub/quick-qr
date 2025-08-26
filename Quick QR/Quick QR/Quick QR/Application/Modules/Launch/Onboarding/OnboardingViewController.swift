//
//  OnboardingScreenViewController.swift
//  PhotoRecovery
//
//  Created by Haider on 27/12/2024.
//

import UIKit
import StoreKit
import GoogleMobileAds

class OnboardingViewController: UIViewController,
                                UICollectionViewDelegate,
                                UICollectionViewDataSource,
                                UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var nextArrowImage: UIImageView!
    @IBOutlet weak var loaderView: UIActivityIndicatorView!
    @IBOutlet weak var nativeAdParentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControlCustom: CustomPageControl!
    @IBOutlet weak var nextButton: UIButton!

    private var hasShownReviewPrompt = false
    private var nativeAdView: NativeAdView!
    var nativeAd: GoogleMobileAds.NativeAd?

    var dataSource: [OnBoarding] = [
        OnBoarding(image: UIImage(named: "onboard1")!, heading: Strings.Label.numberLocator, description: Strings.Label.effortlessly),
        OnBoarding(image: UIImage(named: "onboard2")!, heading: Strings.Label.callerIdentification, description: Strings.Label.uncoverCallersIdentity),
        OnBoarding(image: UIImage(named: "onboard3")!, heading: Strings.Label.searchNumbers, description: Strings.Label.noMoreGuesswork),
        OnBoarding(image: UIImage(named: "onboard4")!, heading: Strings.Label.yourReviewMatters, description: Strings.Label.weAreConstantlyWorking)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        if let googleAd = nativeAd {
            showGoogleNativeAd(nativeAd: googleAd)
        }
    }
    
    //MARK: - Private Methods
    func setup() {
        if AdManager.shared.onboardingReviewEnabled == false {
            dataSource.removeLast()
        }

        if AdManager.shared.splashInterstitial {
            AdManager.shared.loadInterstitialAd(id: AdMobConfig.interstitial) { isLoaded, interstitial in}
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false

        pageControlCustom.numberOfPages = dataSource.count
        self.navigationController?.navigationBar.isHidden = true
        nextButton.layer.cornerRadius = nextButton.frame.width/2
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        
        loaderView.isHidden = true
        loaderView.startAnimating()
    }
    
    func finishOnboarding() {
        if hasShownReviewPrompt || AdManager.shared.onboardingReviewEnabled == false {
            UserDefaults.standard.set(true, forKey: "isOnboardingComplete")
            
            if AdManager.shared.splashInterstitial == true {
                if AdManager.shared.splashInterstitial {
                    AdManager.shared.adCounter = AdManager.shared.maxInterstitalAdCounter
                }
                AdManager.shared.showInterstitial(adId: AdMobConfig.interstitial) {
//                    let navController = UINavigationController(rootViewController:  HomeViewController())
//                    navController.isNavigationBarHidden = true
//                    UIApplication.shared.updateRootViewController(to: navController)
                }
            } else {
//                let navController = UINavigationController(rootViewController:  HomeViewController())
//                navController.isNavigationBarHidden = true
//                UIApplication.shared.updateRootViewController(to: navController)
            }
        } else {
            requestAppStoreReview()
        }
    }
    
    private func loadNativeAd(completion: ((GoogleMobileAds.NativeAd?) -> Void)?) {
        AdManager.shared.loadNativeAd(adId: AdMobConfig.native,
                                      from: self) { googleAd in
            completion?(googleAd)
        }
    }
    
    private func setAdView(_ view: NativeAdView) {
        // Remove the previous ad view
        nativeAdView = view
        nativeAdParentView.addSubview(nativeAdView)
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout constraints for positioning the native ad view
        let viewDictionary = ["_nativeAdView": nativeAdView!]
        nativeAdParentView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[_nativeAdView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
        )
        nativeAdParentView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[_nativeAdView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
        )
    }
    
    private func showGoogleNativeAd(nativeAd: GoogleMobileAds.NativeAd?) {
        guard let nativeAd else { return }
        let nibView = Bundle.main.loadNibNamed("NativeAdView", owner: nil, options: nil)?.first
        guard let nativeAdView = nibView as? NativeAdView else { return }
        setAdView(nativeAdView)

        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent

        // Configure optional assets
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        nativeAdView.bodyView?.isHidden = nativeAd.body == nil
        
        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
        nativeAdView.callToActionView?.layer.cornerRadius = 12.0
        
        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeAdView.iconView?.isHidden = nativeAd.icon == nil
        
        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil
        
        // Disable user interaction on call-to-action view for SDK to handle touches
        nativeAdView.callToActionView?.isUserInteractionEnabled = false
        
        nativeAdView.nativeAd = nativeAd
    }
    
    private func requestAppStoreReview() {
        // Set the flag to indicate we've shown the review prompt
        hasShownReviewPrompt = true
        
        // Request review using StoreKit
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    private func getCurrentPageIndex() -> Int {
        collectionView.layoutIfNeeded()
        
        // Calculate page width
        let pageWidth = collectionView.bounds.width
        
        // Get current offset
        let offsetX = collectionView.contentOffset.x
        
        // Calculate current page - use a small tolerance for floating point precision
        let currentPage = Int((offsetX + pageWidth * 0.5) / pageWidth)
        
        // Clamp to valid range
        return max(0, min(currentPage, dataSource.count - 1))
    }
    
    private func scrollToNextItem() {
        let currentIndex = getCurrentPageIndex()
        let nextIndex = currentIndex + 1
        
        guard nextIndex < dataSource.count else {
            finishOnboarding()
            return
        }
        
        collectionView.layoutIfNeeded() // ensure frames are up-to-date
        
        let indexPath = IndexPath(item: nextIndex, section: 0)
        
        // Try to read the exact attributes frame
        if let attributes = collectionView.layoutAttributesForItem(at: indexPath) {
            // attributes.frame.origin.x is relative to content; to include contentInset properly:
            let targetX = attributes.frame.origin.x - collectionView.contentInset.left
            collectionView.setContentOffset(CGPoint(x: round(targetX), y: 0), animated: true)
        } else {
            // fallback
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    //MARK: - IBActions
    @IBAction func didTapNextButton(_ sender: Any) {
        let currentIndex = getCurrentPageIndex()

          switch currentIndex {
          case 0, 1, 2:
              // Load ad first, then scroll ONCE
              loaderView.isHidden = false
              nextArrowImage.isHidden = true
              loadNativeAd { [weak self] googleAd in
                  guard let self = self else { return }
                  self.nativeAd = googleAd
                  self.showGoogleNativeAd(nativeAd: googleAd)
                  self.scrollToNextItem()
                  
                  loaderView.isHidden = true
                  nextArrowImage.isHidden = false
              }

          case 3:
              if hasShownReviewPrompt {
                  finishOnboarding()
              } else {
                  requestAppStoreReview()
              }

          default:
              scrollToNextItem()
          }
    }
    
    @IBAction func didTapSkipButton(_ sender: Any) {
        finishOnboarding()
    }
    
    //MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = OnBoardingCollectionViewCell.cellForCollectionView(collectionView: collectionView, indexPath: indexPath)
        cell.setupCell(data: dataSource[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        guard let visibleIndexPath = collectionView.indexPathForItem(at: CGPoint(x: visibleRect.midX, y: visibleRect.midY)) else {
            return
        }
        pageControlCustom.currentPage = visibleIndexPath.item
//        skipButton.isHidden = visibleIndexPath.item == dataSource.count - 1
    }
}
