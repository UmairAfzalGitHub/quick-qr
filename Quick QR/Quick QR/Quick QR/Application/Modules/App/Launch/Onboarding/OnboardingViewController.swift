
import UIKit
import StoreKit
import GoogleMobileAds

class OnboardingViewController: BaseViewController,
                                UICollectionViewDelegate,
                                UICollectionViewDataSource,
                                UICollectionViewDelegateFlowLayout,
                                IAPViewControllerDelegate {
    
    @IBOutlet weak var nextButton: AppButtonView!
    @IBOutlet weak var nativeAdParentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControlCustom: CustomPageControl!
    @IBOutlet weak var nativeAdHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nativeAdTopConstraint: NSLayoutConstraint!
    
    // Banner ad view
    private let bannerAdParentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private var bannerView: BannerView!
    private var bannerAdHeightConstraint: NSLayoutConstraint!
    
    private var hasShownReviewPrompt = false
    private var nativeAdView: NativeAdView!
    var nativeAd: GoogleMobileAds.NativeAd?
    
    // Track which floor native ad ID to use
    private var useFirstFloorNativeAd = false
    
    var dataSource: [OnBoarding] = [
        OnBoarding(image: UIImage(named: "onboard1")!, heading: Strings.Label.smartScanQrCode, description: Strings.Label.pointYourCamera),
//        OnBoarding(image: UIImage(named: "onboard2")!, heading: Strings.Label.easilyReadBarcodes, description: Strings.Label.easilyScanBarcodes),
        OnBoarding(image: UIImage(named: "onboard3")!, heading: Strings.Label.quicklyCreateQrCode, description: Strings.Label.generateCustomQr),
//        OnBoarding(image: UIImage(named: "onboard4")!, heading: Strings.Label.helpKeepItFree, description: Strings.Label.showYourLove)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupBannerAdView()
        loadNativeAdIfNeeded()
    }
    
    private func setupBannerAdView() {
        view.addSubview(bannerAdParentView)
        bannerAdParentView.translatesAutoresizingMaskIntoConstraints = false
        bannerAdHeightConstraint = bannerAdParentView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            bannerAdHeightConstraint,
            bannerAdParentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerAdParentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannerAdParentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Create banner view
        bannerView = BannerView()
        bannerAdParentView.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bannerView.topAnchor.constraint(equalTo: bannerAdParentView.topAnchor),
            bannerView.leadingAnchor.constraint(equalTo: bannerAdParentView.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: bannerAdParentView.trailingAnchor),
            bannerView.bottomAnchor.constraint(equalTo: bannerAdParentView.bottomAnchor)
        ])
    }
    
    private func loadNativeAdIfNeeded() {
        nativeAdParentView.isHidden = true
        nativeAdHeightConstraint.constant = 0
        bannerAdParentView.isHidden = true
        bannerAdHeightConstraint.constant = 0

        guard !IAPManager.shared.isUserSubscribed else {
            return
        }

        // First try to get a preloaded floor native ad
        if let ad = AdManager.shared.getNativeAd() {
            print("📢 ONBOARDING: Using preloaded Native Ad")
            nativeAd = ad
            showGoogleNativeAd(nativeAd: nativeAd)
        } else {
            // If no preloaded ad, try to load floor native ad 2 (initially)
            print("📢 ONBOARDING: Loading Native Ad ID-2 (initial)")
            AdManager.shared.loadNativeAd(adId: RemoteConfigManager.shared.floorNativeAd2, from: self) {[weak self] ad in
                if let ad = ad {
                    // If floor native ad loaded successfully, show it
                    print("📢 ONBOARDING: Showing Native Ad ID-2")
                    self?.nativeAd = ad
                    self?.showGoogleNativeAd(nativeAd: ad)
                } else {
                    // If floor native ad failed to load, show banner ad instead
                    print("📢 ONBOARDING: Native Ad ID-2 failed, falling back to Banner Ad ID-2")
                    self?.setupBannerAd()
                }
            }
        }
    }
    
    private func setupBannerAd(withAdId adId: AdMobId? = nil) {
        // Hide native ad view and show banner ad view
        nativeAdParentView.isHidden = true
        nativeAdHeightConstraint.constant = 0
        bannerAdParentView.isHidden = false
        bannerAdHeightConstraint.constant = 60
        nativeAdTopConstraint.constant = 80
        
        // Use BaseViewController's banner implementation
        let bannerAdId = adId ?? RemoteConfigManager.shared.banner2
        print("📢 ONBOARDING: Setting up Banner Ad ID-\(adId?.adId == RemoteConfigManager.shared.banner1.adId ? "1" : "2")")
        super.setupBanner(adId: bannerAdId)
        super.bannerAdView = self.bannerView
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
    override func setup() {
        // First set up the page control with the full count
        pageControlCustom.numberOfPages = dataSource.count
        
        if RemoteConfigManager.shared.onboardingReviewEnabled == false {
             dataSource.removeLast()
            // Update page control AFTER modifying the data source
            pageControlCustom.numberOfPages = dataSource.count
        }
        
        if RemoteConfigManager.shared.splashInterstitialEnabled {
            AdManager.shared.loadInterstitialAd(id: RemoteConfigManager.shared.interstitial) { isLoaded, interstitial in}
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
        
        // Update button title based on current page
        updateButtonTitle()
        
        self.navigationController?.navigationBar.isHidden = true
        
        if UIDevice().isSmallDevice {
            nativeAdHeightConstraint.constant = 159.0
        }
        
        // load interstitial ad
        if RemoteConfigManager.shared.showInterstitalAfterOnboarding {
            AdManager.shared.loadInterstitialAd(id: RemoteConfigManager.shared.interstitial)
        }
    }
    
    // New method to update button title based on current page
    private func updateButtonTitle() {
        let currentIndex = getCurrentPageIndex()
        let isLastPage = currentIndex == dataSource.count - 1
        let title = isLastPage ? Strings.Label.done : Strings.Label.next
        nextButton.configure(with: .primary(title: title, image: nil))
    }
    
    func finishOnboarding() {
        self.movetoNextScreen()
//        showIAP(delegate: self)
    }
    
    private func loadNativeAd(completion: ((GoogleMobileAds.NativeAd?) -> Void)?) {
        AdManager.shared.loadNativeAd(adId: RemoteConfigManager.shared.native, from: self) { googleAd in
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
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: viewDictionary)
        )
        nativeAdParentView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[_nativeAdView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                metrics: nil,
                views: viewDictionary)
        )
    }
    
    private func showGoogleNativeAd(nativeAd: GoogleMobileAds.NativeAd?) {
        guard let nativeAd else { return }
        nativeAdParentView.isHidden = false
        nativeAdHeightConstraint.constant = UIDevice().isSmallDevice ? 159 : 240

        let nibName = UIDevice().isSmallDevice ? "NativeAdView" : "OnBoardingNativeAdView"
        let nibView = Bundle.main.loadNibNamed(nibName, owner: nil, options: nil)?.first
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
        
        // Update button title after scrolling
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.updateButtonTitle()
        }
    }
    
    //MARK: - IBActions
    @objc func didTapNextButton() {
        let currentIndex = getCurrentPageIndex()
        
        // Toggle between floor native ad IDs
        useFirstFloorNativeAd.toggle()
        let floorNativeAdId = useFirstFloorNativeAd ?
            RemoteConfigManager.shared.floorNativeAd1 : 
            RemoteConfigManager.shared.floorNativeAd2
        let bannerAdId = useFirstFloorNativeAd ? 
            RemoteConfigManager.shared.banner1 : 
            RemoteConfigManager.shared.banner2
            
        print("📢 ONBOARDING: Next page will use Native Ad ID-\(useFirstFloorNativeAd ? "1" : "2") and Banner Ad ID-\(useFirstFloorNativeAd ? "1" : "2")") 
        
        switch currentIndex {
        case 0, 1, 2:
            if let googleAd = AdManager.shared.getNativeAd(stopPrefetch: true) {
                self.nativeAd = googleAd
                self.showGoogleNativeAd(nativeAd: googleAd)
            } else {
                // Try to load the alternating floor native ad
                print("📢 ONBOARDING: Loading Native Ad ID-\(useFirstFloorNativeAd ? "1" : "2")")
                AdManager.shared.loadNativeAd(adId: floorNativeAdId, from: self) {[weak self] ad in
                    guard let self = self else { return }
                    if let ad = ad {
                        // If floor native ad loaded successfully, show it
                        print("📢 ONBOARDING: Showing Native Ad ID-\(self.useFirstFloorNativeAd ? "1" : "2")")
                        self.nativeAd = ad
                        self.showGoogleNativeAd(nativeAd: ad)
                    } else {
                        // If floor native ad failed to load, show banner ad instead
                        print("📢 ONBOARDING: Native Ad ID-\(useFirstFloorNativeAd ? "1" : "2") failed, falling back to Banner Ad ID-\(useFirstFloorNativeAd ? "1" : "2")")
                        self.setupBannerAd(withAdId: bannerAdId)
                    }
                }
            }
            self.scrollToNextItem()
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
        
        // Update button title when scrolling
        updateButtonTitle()
        
        // skipButton.isHidden = visibleIndexPath.item == dataSource.count - 1
    }

    // MARK: - IAPViewControllerDelegate

    func cancelAction() {
        showInterstitialIfNeeded()
    }

    func performAction() {
        showInterstitialIfNeeded()
    }

    func showInterstitialIfNeeded() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            if RemoteConfigManager.shared.showInterstitalAfterOnboarding {
                AdManager.shared.showInterstitial(adId: RemoteConfigManager.shared.interstitial) {[weak self] in
                    self?.movetoNextScreen()
                }
            } else {
                self.movetoNextScreen()
            }
        })
    }

    func movetoNextScreen() {
        let nextController = TabBarController()
        // Set the default selected index based on whether the app is running on a simulator
#if targetEnvironment(simulator)
        nextController.selectedIndex = 0 // Create tab for simulator
#else
        nextController.selectedIndex = 2 // Scan tab for real device
#endif
        UserDefaultManager.shared.setValue(.onBoarding(true))
        UIApplication.shared.updateRootViewController(to: nextController)
    }
}
