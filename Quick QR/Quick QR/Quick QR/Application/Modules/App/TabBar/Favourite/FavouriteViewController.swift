//
//  FavouriteViewController.swift
//  Quick QR
//
//  Created by Umair Afzal on 28/08/2025.
//

import UIKit
import IOS_Helpers
import AVFoundation
import GoogleMobileAds
import FirebaseAnalytics

class FavouriteViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, FavoriteCellDelegate {
    
    // MARK: - Properties
    private let tableView = UITableView()
    private let emptyStateView = UIView()
    private var favorites: [FavoriteItem] = []
    
    private var collectionView: UICollectionView!
    private let nativeAdParentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.customColor(fromHex: "0A3853").cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    private var nativeAdView: NativeAdView!
    var nativeAd: GoogleMobileAds.NativeAd?
    var nativeAdHeightConstraint: NSLayoutConstraint!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleSubscriptionPurchased), name: NSNotification.Name("SubscriptionPurchased"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites()
        
        loadNativeAdIfNeeded()
        Analytics.logEvent("Favorite", parameters: nil)
    }
    
    private func loadNativeAdIfNeeded() {
        nativeAdParentView.isHidden = true
        nativeAdHeightConstraint.constant = 0

        guard !IAPManager.shared.isUserSubscribed else {
            return
        }

        if let ad = AdManager.shared.getNativeAd(stopPrefetch: true) {
            nativeAd = ad
            showGoogleNativeAd(nativeAd: nativeAd)
        } else {
            AdManager.shared.loadNativeAd(adId: RemoteConfigManager.shared.native, from: self) {[weak self] ad in
                self?.nativeAd = ad
                self?.showGoogleNativeAd(nativeAd: ad)
            }
        }
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        // Configure navigation bar appearance
        self.navigationItem.title = Strings.Label.favorite
        
        //        // Remove extra space at the top
        navigationController?.navigationBar.isTranslucent = false
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Configure table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FavoriteCell.self, forCellReuseIdentifier: FavoriteCell.identifier)
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.backgroundColor = .white
        tableView.rowHeight = 80
        
        // Remove extra space at the top
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.contentInset = UIEdgeInsets.zero
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        
        // Add table view to view hierarchy
        view.addSubview(tableView)
        view.addSubview(nativeAdParentView)
        nativeAdParentView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        nativeAdHeightConstraint = nativeAdParentView.heightAnchor.constraint(equalToConstant: UIDevice().isSmallDevice ? 159 : 240)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: nativeAdParentView.topAnchor, constant: -10),

            nativeAdHeightConstraint,
            nativeAdParentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
            nativeAdParentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
            nativeAdParentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
        
        // Setup empty state view
        setupEmptyStateView()
    }
    
    // MARK: - Data
    private func loadFavorites() {
        // Get all favorite items from HistoryManager
        favorites = HistoryManager.shared.getFavorites()
        
        // Refresh table view
        tableView.reloadData()
        
        // Show empty state if needed
        if favorites.isEmpty {
            showEmptyState()
        } else {
            hideEmptyState()
        }
    }
    
    // MARK: - UITableViewDelegate & UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.identifier, for: indexPath) as? FavoriteCell else {
            return UITableViewCell()
        }
        
        let favorite = favorites[indexPath.row]
        cell.configure(with: favorite)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let favorite = favorites[indexPath.row]
        // Find the original HistoryItem
        let allCreated = HistoryManager.shared.getCreatedHistory()
        let allScanned = HistoryManager.shared.getScanHistory()
        let historyItem: HistoryItem? = {
            switch favorite.origin {
            case .created:
                return allCreated.first { $0.id == favorite.id }
            case .scanned:
                return allScanned.first { $0.id == favorite.id }
            }
        }()
        guard let item = historyItem else { return }
        switch favorite.origin {
        case .created:
            // Use CodeGenerationResultViewController logic from HistoryViewController
            let resultVC = CodeGenerationResultViewController()
            switch item.type {
            case .qrCode:
                if let qrImage = CodeGeneratorManager.shared.generateQRCode(from: item.content) {
                    resultVC.setQRCodeImage(qrImage)
                }
                resultVC.setTitleAndDescription(title: item.title, description: Strings.Label.qrCode)
                // Set the generated content and pass the item ID since it's already a favorite
                resultVC.setGeneratedContent(item.content, existingItemId: item.id, isFavorite: true)
            case .socialQRCode:
                if let socialType = SocialQRCodeType.allCases.first(where: { $0.title.lowercased() == item.subtype.lowercased() }) {
                    if let qrImage = CodeGeneratorManager.shared.generateSocialQRCode(type: socialType, username: item.content) {
                        resultVC.setQRCodeImage(qrImage)
                    }
                    resultVC.setTitleAndDescription(title: item.title, description: Strings.Label.socialQR)
                    // Set the generated content and pass the item ID since it's already a favorite
                    resultVC.setGeneratedContent(item.content, existingItemId: item.id, isFavorite: true)
                }
            case .barCode:
                if let barType = BarCodeType.allCases.first(where: { $0.title.lowercased() == item.subtype.lowercased() }) {
                    if let barcodeImage = CodeGeneratorManager.shared.generateBarcode(content: item.content, type: barType) {
                        resultVC.setBarCodeImage(barcodeImage)
                        resultVC.setBarCodeType(icon: barType.icon, title: barType.title)
                    }
                    resultVC.setTitleAndDescription(title: item.title, description: Strings.Label.barCode)
                    // Set the generated content and pass the item ID since it's already a favorite
                    resultVC.setGeneratedContent(item.content, existingItemId: item.id, isFavorite: true)
                }
            }
            
            // Set hidesBottomBarWhenPushed to true
            resultVC.hidesBottomBarWhenPushed = true
            
            // Hide tab bar explicitly before showing interstitial
            if let tabBarController = self.tabBarController as? TabBarController {
                tabBarController.setTabBarVisibility(true) // true means hide
            }
            
            AdManager.shared.showInterstitial(adId: RemoteConfigManager.shared.interstitial, from: self) { [weak self] _ in
                // Ensure tab bar is still hidden before pushing
                if let tabBarController = self?.tabBarController as? TabBarController {
                    tabBarController.setTabBarVisibility(true) // true means hide
                }
                self?.navigationController?.pushViewController(resultVC, animated: true)
            }
        case .scanned:
            // Use ScanResultViewController logic from HistoryViewController
            var metadataType: AVMetadataObject.ObjectType = .qr
            if let barType = BarCodeType.allCases.first(where: { $0.title.lowercased() == item.subtype.lowercased() }) {
                metadataType = barType.metadataObjectType
            } else if let _ = QRCodeType.allCases.first(where: { $0.title.lowercased() == item.subtype.lowercased() }) {
                metadataType = .qr
            } else if let _ = SocialQRCodeType.allCases.first(where: { $0.title.lowercased() == item.subtype.lowercased() }) {
                metadataType = .qr
            }
            let scanResultVC = ScanResultViewController(scannedData: item.content, metadataObjectType: metadataType)
            scanResultVC.intent = .history
            // Pass the item ID and favorite status
            scanResultVC.setExistingItemId(item.id, isFavorite: true)
            
            // Set hidesBottomBarWhenPushed to true
            scanResultVC.hidesBottomBarWhenPushed = true
            
            // Hide tab bar explicitly before showing interstitial
            if let tabBarController = self.tabBarController as? TabBarController {
                tabBarController.setTabBarVisibility(true) // true means hide
            }
            
            AdManager.shared.showInterstitial(adId: RemoteConfigManager.shared.interstitial, from: self) { [weak self] _ in
                // Ensure tab bar is still hidden before pushing
                if let tabBarController = self?.tabBarController as? TabBarController {
                    tabBarController.setTabBarVisibility(true) // true means hide
                }
                self?.navigationController?.pushViewController(scanResultVC, animated: true)
            }
        }
    }
    
    // MARK: - FavoriteCellDelegate
    
    func didTapFavouriteButton(cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        // Get the item ID from our data source
        let itemId = favorites[indexPath.row].id
        
        // Toggle favorite status in the history manager (will unfavorite it)
        let isFavorite = HistoryManager.shared.toggleFavorite(forItemWithId: itemId)
        
        // Since this is the favorites tab, if it's still marked as favorite (which shouldn't happen),
        // we need to update the UI to reflect the current state
        if !isFavorite {
            // Remove from our data source
            favorites.remove(at: indexPath.row)
            
            // Animate the removal
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // Show empty state if needed
            if favorites.isEmpty {
                showEmptyState()
            }
        } else {
            // Just reload the row if for some reason it's still favorited
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func didTapOptionsButton(cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        // Get the item from our data source
        let item = favorites[indexPath.row]
        
        // Show action sheet to handle the menu item selection
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Add share action
        actionSheet.addAction(UIAlertAction(title: Strings.Label.share, style: .default) { [weak self] _ in
            self?.shareFavoriteItem(at: indexPath)
        })
        
        // Add delete action
        actionSheet.addAction(UIAlertAction(title: Strings.Label.delete, style: .destructive) { [weak self] _ in
            self?.deleteFavoriteItem(at: indexPath)
        })
        
        // Add cancel action
        actionSheet.addAction(UIAlertAction(title: Strings.Label.cancel, style: .cancel, handler: nil))
        
        // Present the action sheet
        present(actionSheet, animated: true)
    }
    
    private func shareFavoriteItem(at indexPath: IndexPath) {
        // Generate the image to share based on the favorite item
        let item = favorites[indexPath.row]
        var imageToShare: UIImage?
        
        switch item.type {
        case .qrCode(let qrType):
            imageToShare = CodeGeneratorManager.shared.generateQRCode(from: item.url)
        case .socialQRCode(let socialType):
            if let socialType = SocialQRCodeType.allCases.first(where: { $0.title.lowercased() == item.title.lowercased() }) {
                imageToShare = CodeGeneratorManager.shared.generateSocialQRCode(type: socialType, username: item.url)
            }
        case .barCode(let barType):
            if let barType = BarCodeType.allCases.first(where: { $0.title.lowercased() == item.title.lowercased() }) {
                imageToShare = CodeGeneratorManager.shared.generateBarcode(content: item.url, type: barType)
            }
        }
        
        // Share the image if available
        if let image = imageToShare {
            let activityViewController = UIActivityViewController(activityItems: ["Check this out", image], applicationActivities: nil)
            present(activityViewController, animated: true)
        } else {
            // If no image, share the text content
            let activityViewController = UIActivityViewController(activityItems: ["Check this out", item.url], applicationActivities: nil)
            present(activityViewController, animated: true)
        }
    }
    
    private func deleteFavoriteItem(at indexPath: IndexPath) {
        // Get the item ID from our data source
        let itemId = favorites[indexPath.row].id
        
        // Delete the item from favorites only, not from history
        HistoryManager.shared.deleteFavoriteItem(withId: itemId)
        
        // Remove from data source
        favorites.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        
        // Show empty state if needed
        if favorites.isEmpty {
            showEmptyState()
        }
    }
    
    // MARK: - Empty State Handling
    
    private func setupEmptyStateView() {
        emptyStateView.isHidden = true
        view.addSubview(emptyStateView)
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
        ])
        
        let imageView = UIImageView(image: UIImage(systemName: "heart"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .appPrimary

        let titleLabel = UILabel()
        titleLabel.text = Strings.Label.noFavoritesYet
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textAlignment = .center
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = Strings.Label.tapTheHeart
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .systemGray
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .center
        
        emptyStateView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            stackView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }
    
    private func showEmptyState() {
        tableView.isHidden = true
        emptyStateView.isHidden = false
    }
    
    private func hideEmptyState() {
        tableView.isHidden = false
        emptyStateView.isHidden = true
    }
    
    // MARK: - Private Methods:

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
    
    override func handleSubscriptionPurchased() {
        super.handleSubscriptionPurchased()
        hideAds()
    }
    
    private func hideAds() {
        nativeAdParentView.isHidden = true
        nativeAdHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - Models
struct FavoriteItem {
    enum ItemType {
        case qrCode(QRCodeType)
        case socialQRCode(SocialQRCodeType)
        case barCode(BarCodeType)
    }
    enum Origin {
        case created
        case scanned
    }
    let type: ItemType
    let title: String
    let url: String
    let id: String
    var isFavorite: Bool
    let origin: Origin
    
    init(type: ItemType, title: String, url: String, id: String = UUID().uuidString, isFavorite: Bool = false, origin: Origin) {
        self.type = type
        self.title = title
        self.url = url
        self.id = id
        self.isFavorite = isFavorite
        self.origin = origin
    }
}
