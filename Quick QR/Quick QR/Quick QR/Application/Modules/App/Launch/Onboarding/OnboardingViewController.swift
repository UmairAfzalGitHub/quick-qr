
import UIKit
import StoreKit
import GoogleMobileAds

class OnboardingViewController: UIViewController,
                                UICollectionViewDelegate,
                                UICollectionViewDataSource,
                                UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var nextButton: AppButtonView!
    @IBOutlet weak var nativeAdParentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControlCustom: CustomPageControl!

    private var hasShownReviewPrompt = false
    private var nativeAdView: NativeAdView!
    var nativeAd: GoogleMobileAds.NativeAd?

    var dataSource: [OnBoarding] = [
        OnBoarding(image: UIImage(named: "onboard1")!, heading: Strings.Label.smartScanQrCode, description: Strings.Label.pointYourCamera),
        OnBoarding(image: UIImage(named: "onboard2")!, heading: Strings.Label.easilyReadBarcodes, description: Strings.Label.easilyScanBarcodes),
        OnBoarding(image: UIImage(named: "onboard3")!, heading: Strings.Label.quicklyCreateQrCode, description: Strings.Label.generateCustomQr)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        nativeAd = AdManager.shared.getNativeAd()
        if let googleAd = nativeAd {
            showGoogleNativeAd(nativeAd: googleAd)
        } else {
            AdManager.shared.loadNativeAd(adId: AdMobConfig.native, from: self) {[weak self] ad in
                self?.nativeAd = ad
                self?.showGoogleNativeAd(nativeAd: ad)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update flow layout item size to match collection view bounds
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = collectionView.bounds.size
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    //MARK: - Private Methods
    func setup() {
        // First set up the page control with the full count
        pageControlCustom.numberOfPages = 3
        
        if AdManager.shared.onboardingReviewEnabled == false {
//            dataSource.removeLast()
            // Update page control AFTER modifying the data source
            //pageControlCustom.numberOfPages = dataSource.count
        }

        if AdManager.shared.splashInterstitial {
            AdManager.shared.loadInterstitialAd(id: AdMobConfig.interstitial) { isLoaded, interstitial in}
        }
        
        // Configure collection view layout
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
            flowLayout.minimumInteritemSpacing = 0
            // This ensures cells are properly sized
            flowLayout.estimatedItemSize = .zero
            flowLayout.itemSize = collectionView.frame.size
        }
        
        collectionView.isPagingEnabled = true // Enable paging for smooth scrolling
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false // Prevent bouncing at edges
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.reloadData()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapNextButton))
        nextButton.addGestureRecognizer(tapGestureRecognizer)
        nextButton.configure(with: .primary(title: Strings.Label.next, image: nil))
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func finishOnboarding() {
        UIApplication.shared.updateRootViewController(to: LanguageSelectionViewController())
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
        let nibView = Bundle.main.loadNibNamed("OnBoardingNativeAdView", owner: nil, options: nil)?.first
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
        
        // Calculate the target X offset based on page width
        let pageWidth = collectionView.frame.width
        let targetX = CGFloat(nextIndex) * pageWidth
        
        // Use setContentOffset with animated:true to maintain vertical position
        collectionView.setContentOffset(CGPoint(x: targetX, y: 0), animated: true)
        
        // Update page control
        pageControlCustom.currentPage = nextIndex
    }
    
    //MARK: - IBActions
    @objc func didTapNextButton() {
        let currentIndex = getCurrentPageIndex()

          switch currentIndex {
          case 0, 1:
              if let googleAd = AdManager.shared.getNativeAd(stopPrefetch: true) {
                  self.nativeAd = googleAd
                  self.showGoogleNativeAd(nativeAd: googleAd)
              }
              self.scrollToNextItem()
          case 2:
              finishOnboarding()
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
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Force Y offset to always be 0 to prevent vertical shifting
        if scrollView.contentOffset.y != 0 {
            scrollView.contentOffset.y = 0
        }
        
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        guard let visibleIndexPath = collectionView.indexPathForItem(at: CGPoint(x: visibleRect.midX, y: visibleRect.midY)) else {
            return
        }
        pageControlCustom.currentPage = visibleIndexPath.item
//        skipButton.isHidden = visibleIndexPath.item == dataSource.count - 1
    }
}
