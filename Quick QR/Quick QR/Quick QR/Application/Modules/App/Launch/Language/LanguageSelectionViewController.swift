//
//  LanguageSelectionViewController.swift
//
//
//  Created by Haider Rathore on 26/08/2025.
//

import UIKit
import GoogleMobileAds

enum LanguageIntent {
    case onBoarding
    case settings
}

class LanguageSelectionViewController: BaseViewController {
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.Label.selectLanguage
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    private let selectCTA: AppButtonView = {
        let view = AppButtonView()
        view.configure(with: .primary(title: Strings.Label.select, image: nil))
        return view
    }()
    
    private var collectionView: UICollectionView!
    
    private let nativeAdParentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.customColor(fromHex: "0A3853").cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    private var nativeAdView: NativeAdView!
    var nativeAdHeightConstraint: NSLayoutConstraint!
    var nativeAd: GoogleMobileAds.NativeAd?
    
    // Banner ad view
    private let bannerAdParentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private var bannerView: BannerView!
    var bannerAdHeightConstraint: NSLayoutConstraint!
    var intent: LanguageIntent = .onBoarding
    var selected = String()
    
    private var languages: [Language] = [
        Language(title: "English", flagImage: "uk-flag", isSelected: false, languageCode: "en"),
        Language(title: "Arabic (العربية)", flagImage: "arabic-flag", isSelected: false, languageCode: "ar"),
        Language(title: "Japanese (日本語)", flagImage: "japanese-flag", isSelected: false, languageCode: "ja"),
        Language(title: "French (Français)", flagImage: "french-flag", isSelected: false, languageCode: "fr"),
        Language(title: "German (Deutsch)", flagImage: "german-flag", isSelected: false, languageCode: "de"),
        Language(title: "Dutch (Nederlands)", flagImage: "dutch-flag", isSelected: false, languageCode: "nl"),
        Language(title: "Portuguese (Português)", flagImage: "portuguese-flag", isSelected: false, languageCode: "pt-BR"),
        Language(title: "Hindi (हिन्दी)", flagImage: "hindi-flag", isSelected: false, languageCode: "hi"),
        Language(title: "Russian (Русский)", flagImage: "russian-flag", isSelected: false, languageCode: "ru"),
        Language(title: "Spanish (Español)", flagImage: "spanish-flag", isSelected: false, languageCode: "es"),
        Language(title: "Korean (한국어)", flagImage: "korean-flag", isSelected: false, languageCode: "ko"),
        Language(title: "Turkish (Türkçe)", flagImage: "turkish-flag", isSelected: false, languageCode: "tr"),
        Language(title: "Vietnamese (Tiếng Việt)", flagImage: "vietnamese-flag", isSelected: false, languageCode: "vi")
    ]

    private var selectedIndex: IndexPath?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCollectionView()
        setupLayout()
        loadNativeAdIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            nativeAd = ad
            showGoogleNativeAd(nativeAd: nativeAd)
        } else {
            // If no preloaded ad, try to load floor native ad 1
            print("📢 LANGUAGE: Loading Native Ad ID-1")
            AdManager.shared.loadNativeAd(adId: RemoteConfigManager.shared.floorNativeAd1, from: self) {[weak self] ad in
                if let ad = ad {
                    // If floor native ad loaded successfully, show it
                    print("📢 LANGUAGE: Showing Native Ad ID-1")
                    self?.nativeAd = ad
                    self?.showGoogleNativeAd(nativeAd: ad)
                } else {
                    // If floor native ad failed to load, show banner ad instead
                    print("📢 LANGUAGE: Native Ad ID-1 failed, falling back to Banner Ad ID-1")
                    self?.setupBannerAd()
                }
            }
        }
    }
    
    private func setupBannerAd() {
        // Hide native ad view and show banner ad view
        nativeAdParentView.isHidden = true
        nativeAdHeightConstraint.constant = 0
        bannerAdParentView.isHidden = false
        bannerAdHeightConstraint.constant = 60
        
        // Check if bannerView exists
        if bannerView == nil {
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
        
        // Use BaseViewController's banner implementation with banner1
        print("📢 LANGUAGE: Setting up Banner Ad ID-1")
        super.setupBanner(adId: RemoteConfigManager.shared.banner1)
        super.bannerAdView = self.bannerView
    }
    
    // MARK: - Setup Collection View
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 16
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(LanguageCell.self, forCellWithReuseIdentifier: "LanguageCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSelect))
        selectCTA.addGestureRecognizer(tapGesture)
        selectCTA.setEnabled(false)
    }
    
    // MARK: - Setup Layout
    private func setupLayout() {
        let headerStack = UIStackView(arrangedSubviews: [titleLabel, UIView(), selectCTA])
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = 8
        
        view.addSubview(headerStack)
        view.addSubview(collectionView)
        view.addSubview(nativeAdParentView)
        view.addSubview(bannerAdParentView)
        
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        nativeAdParentView.translatesAutoresizingMaskIntoConstraints = false
        bannerAdParentView.translatesAutoresizingMaskIntoConstraints = false
        selectCTA.translatesAutoresizingMaskIntoConstraints = false
        nativeAdHeightConstraint = nativeAdParentView.heightAnchor.constraint(equalToConstant: UIDevice().isSmallerDevice() ? 159 : 240)
        bannerAdHeightConstraint = bannerAdParentView.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            selectCTA.widthAnchor.constraint(equalToConstant: 120),
            selectCTA.heightAnchor.constraint(equalToConstant: 54),
            
            collectionView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: nativeAdParentView.topAnchor, constant: -10),
            
            nativeAdHeightConstraint,
            nativeAdParentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
            nativeAdParentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
            nativeAdParentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            bannerAdHeightConstraint,
            bannerAdParentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerAdParentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannerAdParentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setAdView(_ view: NativeAdView) {
        // Remove the previous ad view
        if nativeAdView != nil {
            nativeAdView.removeFromSuperview()
        }

        nativeAdView = view
        nativeAdView.tag = 2500
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
        nativeAdParentView.isHidden = false
        nativeAdHeightConstraint.constant = UIDevice().isSmallerDevice() ? 159 : 240

        let nibName = UIDevice().isSmallerDevice() ? "NativeAdView" : "OnBoardingNativeAdView"
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

    @objc private func didTapSelect() {
        if let selectedIndex = selectedIndex {
            selectLanguage(indexNo: selectedIndex)
        } else {
            print("No language selected")
            return
        }
        
        if intent == .settings {
            let tabVC = TabBarController()
            tabVC.selectedIndex = 4
            UIApplication.shared.updateRootViewController(to: tabVC)
            return
        }

        if RemoteConfigManager.shared.splashInterstitialEnabled == true {
            if RemoteConfigManager.shared.splashInterstitialEnabled {
                AdManager.shared.adCounter = RemoteConfigManager.shared.maxInterstitalAdCounter
                AdManager.shared.showInterstitial(adId: RemoteConfigManager.shared.interstitial) {[weak self] in
                    self?.navigateToOnBoarding()
                }
            }
        } else {
            navigateToOnBoarding()
        }
    }
    
    func navigateToOnBoarding() {
        let controller = OnboardingViewController()
        let navController = UINavigationController(rootViewController: controller)
        navController.isNavigationBarHidden = true
        UIApplication.shared.updateRootViewController(to: navController)
    }
}

// MARK: - CollectionView Delegate & DataSource
extension LanguageSelectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return languages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LanguageCell", for: indexPath) as! LanguageCell
        let lang = languages[indexPath.item]
        cell.configure(with: lang, isSelected: selectedIndex == indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let previous = selectedIndex
        selectedIndex = indexPath
        var reloads: [IndexPath] = [indexPath]
        if let prev = previous { reloads.append(prev) }
        collectionView.reloadItems(at: reloads)
        selectCTA.setEnabled(true)
    }
    
    // Grid layout 2 columns
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 16)
        return CGSize(width: width, height: 68)
    }
    
    func selectLanguage(indexNo : IndexPath) {
        let diplayLangArray = languages

        print(diplayLangArray[indexNo.row].title)
        self.selected = diplayLangArray[indexNo.row].title
        
        LanguageManager.storeCurrentLanguage(code: diplayLangArray[indexNo.row].languageCode)
        UserDefaults.standard.set(diplayLangArray[indexNo.row].title, forKey: "DisplayLang")
        UIView.appearance().semanticContentAttribute = LanguageManager.currentSemantic()
        UINavigationBar.appearance().semanticContentAttribute = LanguageManager.currentSemantic()
    }
}

// MARK: - Custom Cell
class LanguageCell: UICollectionViewCell {
    
    private let cellContentView = UIView()
    private let flagImageView = UIImageView()
    private let nameLabel = UILabel()
    private let checkmarkImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Setup content container (border + radius only, no shadow here)
        cellContentView.layer.cornerRadius = 7
        cellContentView.layer.borderColor = UIColor.appBorderDark.cgColor
        cellContentView.layer.borderWidth = 1
        cellContentView.backgroundColor = .white
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cellContentView)

        flagImageView.contentMode = .scaleAspectFit
        flagImageView.clipsToBounds = true
        flagImageView.layer.cornerRadius = 4
        
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        nameLabel.textColor = .black
        
        checkmarkImageView.contentMode = .scaleAspectFit
        checkmarkImageView.isHidden = true
        checkmarkImageView.image = UIImage(named: "checkmark-selected")
        
        let stack = UIStackView(arrangedSubviews: [flagImageView, nameLabel, checkmarkImageView])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 6
        
        cellContentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cellContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            cellContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            cellContentView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            cellContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
            
            stack.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -8),
            stack.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor, constant: -8)
        ])
        
        flagImageView.widthAnchor.constraint(equalToConstant: 38).isActive = true
        flagImageView.heightAnchor.constraint(equalToConstant: 38).isActive = true
        checkmarkImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        checkmarkImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        // Important: shadow setup on CELL itself
        contentView.layer.masksToBounds = false
        layer.masksToBounds = false
    }
    
    func configure(with language: Language, isSelected: Bool) {
        flagImageView.image = UIImage(named: language.flagImage)
        nameLabel.text = language.title
        checkmarkImageView.isHidden = !isSelected
        
        if isSelected {
            cellContentView.layer.borderColor = UIColor.appPrimary.cgColor
            cellContentView.layer.borderWidth = 1

            layer.shadowColor = UIColor.appPrimary.cgColor
            layer.shadowOpacity = 0.4
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowRadius = 6
        } else {
            cellContentView.layer.borderColor = UIColor.appBorderDark.cgColor
            layer.shadowOpacity = 0
        }
    }
}
