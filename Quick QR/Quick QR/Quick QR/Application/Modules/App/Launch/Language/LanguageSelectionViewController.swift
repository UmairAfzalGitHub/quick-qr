//
//  LanguageSelectionViewController.swift
//
//
//  Created by Haider Rathore on 26/08/2025.
//

import UIKit
import GoogleMobileAds

class LanguageSelectionViewController: UIViewController {
    
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
        view.backgroundColor = .systemOrange
        return view
    }()
    
    private var nativeAdView: NativeAdView!
    var nativeAd: GoogleMobileAds.NativeAd?

    // MARK: - Data
    struct Language {
        let name: String
        let flag: UIImage?
    }
    
    private var languages: [Language] = [
        Language(name: "Arabic", flag: UIImage(named: "saudi-arabia-flag")),
        Language(name: "Chinese", flag: UIImage(named: "china-flag")),
        Language(name: "English", flag: UIImage(named: "uk-flag")),
        Language(name: "French", flag: UIImage(named: "france-flag")),
        Language(name: "Hindi", flag: UIImage(named: "india-flag")),
        Language(name: "Indonesia", flag: UIImage(named: "indonesia-flag")),
        Language(name: "Italian", flag: UIImage(named: "italy-flag")),
        Language(name: "Russian", flag: UIImage(named: "russia-flag")),
        Language(name: "Spanish", flag: UIImage(named: "spain-flag")),
        Language(name: "Urdu", flag: UIImage(named: "pakistan-flag"))
    ]
    
    private var selectedIndex: IndexPath?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCollectionView()
        setupLayout()
        
        nativeAd = AdManager.shared.getNativeAd()
        showGoogleNativeAd(nativeAd: nativeAd)
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
        
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        nativeAdParentView.translatesAutoresizingMaskIntoConstraints = false
        selectCTA.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            selectCTA.widthAnchor.constraint(equalToConstant: 120),
            selectCTA.heightAnchor.constraint(equalToConstant: 54),
            
            collectionView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: nativeAdParentView.topAnchor, constant: -10),
            
            nativeAdParentView.heightAnchor.constraint(equalToConstant: 240),
            nativeAdParentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nativeAdParentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            nativeAdParentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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
//        nativeAdView.iconView?.isHidden = nativeAd.icon == nil
        
        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
//        nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil
        
        // Disable user interaction on call-to-action view for SDK to handle touches
        nativeAdView.callToActionView?.isUserInteractionEnabled = false
        
        nativeAdView.nativeAd = nativeAd
    }


    @objc private func didTapSelect() {
        UserDefaults.standard.set(true, forKey: "isOnboardingComplete")

        if AdManager.shared.splashInterstitial == true {
            if AdManager.shared.splashInterstitial {
                AdManager.shared.adCounter = AdManager.shared.maxInterstitalAdCounter
            }
            AdManager.shared.showInterstitial(adId: AdMobConfig.interstitial) {
                let navController = TabBarController()
                UIApplication.shared.updateRootViewController(to: navController)
            }
        } else {
            let navController = TabBarController()
            UIApplication.shared.updateRootViewController(to: navController)
        }
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
        let width = (collectionView.frame.width - 16) / 2
        return CGSize(width: width, height: 64)
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
            cellContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            cellContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            cellContentView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cellContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
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
    
    func configure(with language: LanguageSelectionViewController.Language, isSelected: Bool) {
        flagImageView.image = language.flag
        nameLabel.text = language.name
        checkmarkImageView.isHidden = !isSelected
        
        if isSelected {
            cellContentView.layer.borderColor = UIColor.appPrimary.cgColor
            cellContentView.layer.borderWidth = 1

            // Apply shadow to CELL, not inner view
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
