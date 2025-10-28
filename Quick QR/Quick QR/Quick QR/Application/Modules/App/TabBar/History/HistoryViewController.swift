//
//  HistoryViewController.swift
//  Quick QR
//
//  Created by Umair Afzal on 29/08/2025.
//

import Foundation
import UIKit
import BetterSegmentedControl
import IOS_Helpers
import AVFoundation
import GoogleMobileAds

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FavoriteCellDelegate {
    
    private let betterSegmentedControl: BetterSegmentedControl = {
        let control = BetterSegmentedControl(
            frame: CGRect.zero,
            segments: LabelSegment.segments(withTitles: [Strings.Label.scan,Strings.Label.created],
                                            normalFont: UIFont.systemFont(ofSize: 16, weight: .semibold),
                                          normalTextColor: UIColor.systemGray,
                                            selectedFont: UIFont.systemFont(ofSize: 16, weight: .semibold),
                                          selectedTextColor: UIColor.white),
            options: [.backgroundColor(.appSecondaryBackground),
                      .indicatorViewBackgroundColor(.appPrimary),
                     .cornerRadius(27),
                     .animationSpringDamping(1.0),
                     .animationDuration(0.3)])
        control.indicatorViewInset = 6.0
        control.indicatorView.addSoftShadow()
        control.setIndex(0)
        return control
    }()
    
    private let tableView = UITableView()
    private let emptyStateView = UIView()
    private var isScanSelected: Bool {
        return betterSegmentedControl.index == 0
    }
    
    private var dataSource: [FavoriteItem] = []
    private var scanDataSource: [HistoryItem] = []
    private var createdDataSource: [HistoryItem] = []

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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadHistory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Fetch and store both scan and created history
        scanDataSource = HistoryManager.shared.getScanHistory()
        createdDataSource = HistoryManager.shared.getCreatedHistory()
        loadHistory()
        // Update clear button visibility based on data
        navigationItem.rightBarButtonItem?.isEnabled = !dataSource.isEmpty
        
        loadNativeAdIfNeeded()
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
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Add Better Segmented Control
        view.addSubview(betterSegmentedControl)
        betterSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        // Add value changed action
        betterSegmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            betterSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            betterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            betterSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            betterSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            betterSegmentedControl.heightAnchor.constraint(equalToConstant: 54)
        ])
        
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
            tableView.topAnchor.constraint(equalTo: betterSegmentedControl.bottomAnchor, constant: 20),
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

    private func loadHistory() {
        let historyItems = isScanSelected ? 
            HistoryManager.shared.getScanHistory() : 
            HistoryManager.shared.getCreatedHistory()
        let origin: FavoriteItem.Origin = isScanSelected ? .scanned : .created
        dataSource = historyItems.map { $0.toFavoriteItem(origin: origin) }
        tableView.reloadData()
        
        // Show empty state if needed
        if dataSource.isEmpty {
            showEmptyState()
        } else {
            hideEmptyState()
        }
    }
    
    @objc private func segmentChanged(_ sender: BetterSegmentedControl) {
        // Reload history when segment changes
        loadHistory()
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
        
        let imageView = UIImageView(image: UIImage(systemName: "clock.arrow.circlepath"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .appPrimary
        
        let titleLabel = UILabel()
        titleLabel.text = Strings.Label.noHistoryYet
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textAlignment = .center
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = Strings.Label.yourGeneratedCodes
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
    
    // MARK: - UITableViewDelegate & UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.identifier, for: indexPath) as? FavoriteCell else {
            return UITableViewCell()
        }
        
        let favorite = dataSource[indexPath.row]
        cell.configure(with: favorite)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Only handle selection in the Created tab
        if !isScanSelected {
            // Use local createdDataSource
            guard indexPath.row < createdDataSource.count else { return }
            let selectedItem = createdDataSource[indexPath.row]

            let resultVC = CodeGenerationResultViewController()
            switch selectedItem.type {
            case .qrCode:
                if let qrImage = CodeGeneratorManager.shared.generateQRCode(from: selectedItem.content) {
                    resultVC.setQRCodeImage(qrImage)
                }
                resultVC.setTitleAndDescription(title: selectedItem.title, description: Strings.Label.qrCode)
            case .socialQRCode:
                if let socialType = SocialQRCodeType.allCases.first(where: { $0.title.lowercased() == selectedItem.subtype.lowercased() }) {
                    if let qrImage = CodeGeneratorManager.shared.generateSocialQRCode(type: socialType, username: selectedItem.content) {
                        resultVC.setQRCodeImage(qrImage)
                    }
                    resultVC.setTitleAndDescription(title: selectedItem.title, description: Strings.Label.socialQR)
                }
            case .barCode:
                if let barType = BarCodeType.allCases.first(where: { $0.title.lowercased() == selectedItem.subtype.lowercased() }) {
                    if let barcodeImage = CodeGeneratorManager.shared.generateBarcode(content: selectedItem.content, type: barType) {
                        resultVC.setBarCodeImage(barcodeImage)
                        resultVC.setBarCodeType(icon: barType.icon, title: barType.title)
                    }
                    resultVC.setTitleAndDescription(title: selectedItem.title, description: Strings.Label.barCode)
                }
            }
            
            // Set hidesBottomBarWhenPushed to true
            resultVC.hidesBottomBarWhenPushed = true
            
            // Hide tab bar explicitly before showing interstitial
            if let tabBarController = self.tabBarController as? TabBarController {
                tabBarController.setTabBarVisibility(true) // true means hide
            }
            
            AdManager.shared.showInterstitial(adId: RemoteConfigManager.shared.interstitial, from: self) {
                // Ensure tab bar is still hidden before pushing
                if let tabBarController = self.tabBarController as? TabBarController {
                    tabBarController.setTabBarVisibility(true) // true means hide
                }
                self.navigationController?.pushViewController(resultVC, animated: true)
            }
        } else {
            // Use local scanDataSource
            guard indexPath.row < scanDataSource.count else { return }
            let selectedItem = scanDataSource[indexPath.row]
            // Try to infer code type
            var metadataType: AVMetadataObject.ObjectType = .qr
            // If the subtype matches a barcode type, treat as barcode
            if let barType = BarCodeType.allCases.first(where: { $0.title.lowercased() == selectedItem.subtype.lowercased() }) {
                metadataType = barType.metadataObjectType
            } else if let _ = QRCodeType.allCases.first(where: { $0.title.lowercased() == selectedItem.subtype.lowercased() }) {
                metadataType = .qr
            } else if let _ = SocialQRCodeType.allCases.first(where: { $0.title.lowercased() == selectedItem.subtype.lowercased() }) {
                metadataType = .qr
            }
            let scanResultVC = ScanResultViewController(scannedData: selectedItem.content, metadataObjectType: metadataType)
            scanResultVC.intent = .history
            
            // Set hidesBottomBarWhenPushed to true
            scanResultVC.hidesBottomBarWhenPushed = true
            
            // Hide tab bar explicitly before showing interstitial
            if let tabBarController = self.tabBarController as? TabBarController {
                tabBarController.setTabBarVisibility(true) // true means hide
            }
            
            AdManager.shared.showInterstitial(adId: RemoteConfigManager.shared.interstitial, from: self) {
                // Ensure tab bar is still hidden before pushing
                if let tabBarController = self.tabBarController as? TabBarController {
                    tabBarController.setTabBarVisibility(true) // true means hide
                }
                self.navigationController?.pushViewController(scanResultVC, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Get the history items
            let historyItems = isScanSelected ? 
                HistoryManager.shared.getScanHistory() : 
                HistoryManager.shared.getCreatedHistory()
            
            // Delete the item from history manager
            if indexPath.row < historyItems.count {
                let itemToDelete = historyItems[indexPath.row]
                HistoryManager.shared.deleteHistoryItem(withId: itemToDelete.id)
                
                // Remove from data source
                dataSource.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                // Show empty state if needed
                if dataSource.isEmpty {
                    showEmptyState()
                }
            }
        }
    }
    
    // MARK: - FavoriteCellDelegate
    
    func didTapFavouriteButton(cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        // Get the item ID from our data source
        let itemId = dataSource[indexPath.row].id
        
        // Toggle favorite status in the history manager
        let newFavoriteStatus = HistoryManager.shared.toggleFavorite(forItemWithId: itemId)
        
        // Update our data source
        dataSource[indexPath.row].isFavorite = newFavoriteStatus
        
        // Reload just this cell to update the UI
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func didTapOptionsButton(cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        // Get the item from our data source
        let item = dataSource[indexPath.row]
        
        // Show action sheet to handle the menu item selection
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Add share action
        actionSheet.addAction(UIAlertAction(title: Strings.Label.share, style: .default) { [weak self] _ in
            self?.shareHistoryItem(at: indexPath)
        })
        
        // Add delete action
        actionSheet.addAction(UIAlertAction(title: Strings.Label.delete, style: .destructive) { [weak self] _ in
            self?.deleteHistoryItem(at: indexPath)
        })
        
        // Add cancel action
        actionSheet.addAction(UIAlertAction(title: Strings.Label.cancel, style: .cancel, handler: nil))
        
        // Present the action sheet
        present(actionSheet, animated: true)
    }
    
    private func shareHistoryItem(at indexPath: IndexPath) {
        // Generate the image to share based on the history item
        let item = dataSource[indexPath.row]
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
    
    private func deleteHistoryItem(at indexPath: IndexPath) {
        // Get the history items
        let historyItems = isScanSelected ? 
            HistoryManager.shared.getScanHistory() : 
            HistoryManager.shared.getCreatedHistory()
        
        // Delete the item from history manager
        if indexPath.row < historyItems.count {
            let itemToDelete = historyItems[indexPath.row]
            
            // This will delete from history but keep in favorites if it's favorited
            HistoryManager.shared.deleteHistoryItem(withId: itemToDelete.id)
            
            // Remove from data source
            dataSource.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // Show empty state if needed
            if dataSource.isEmpty {
                showEmptyState()
            }
        }
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
}
