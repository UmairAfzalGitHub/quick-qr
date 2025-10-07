//
//  CodeGenerationResultViewController.swift
//  Quick QR
//
//  Created by Haider Rathore on 30/08/2025.
//

import UIKit
import Photos
import GoogleMobileAds

class CodeGenerationResultViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let codeContentView = UIView()
    private let qrCodeImageView = UIImageView()
    
    private let barcodeView = UIView()
    private let barcodeContentStackView = UIStackView()
    private let barCodeTypeImageView = UIImageView()
    private let barCodeTypeTitleLabel = UILabel()
    private let barCodeImageView = UIImageView()

    private let titleLabel = UILabel()
    private let descLabel = UILabel()
    
    private let buttonsStackView = UIStackView()
    private let shareButton = AppButtonView()
    private let saveButton = AppButtonView()
    
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

    // MARK: - Properties
    
    private var saveAction: (() -> Void)?
    private var shareAction: (() -> Void)?
    private var existingItemId: String?
    private var generatedContent: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set this view controller to hide the tab bar
        self.hidesBottomBarWhenPushed = true
        view.backgroundColor = .appSecondaryBackground
        
        // Check if this content already exists and is favorited
        if let content = generatedContent {
            let favoriteStatus = HistoryManager.shared.isContentFavorited(content)
            
            // Add heart button with correct initial state
            let heartImageName = favoriteStatus.isFavorite ? "heart-fill" : "heart-empty"
            let heartImage = UIImage(named: heartImageName)
            let heartButton = UIBarButtonItem(image: heartImage, style: .plain, target: self, action: #selector(toggleFavoriteTapped))
            
            // Set the tint color to red if favorited
            if favoriteStatus.isFavorite {
                heartButton.tintColor = .systemRed
            }
            
            navigationItem.rightBarButtonItem = heartButton
            
            // Store the item ID if it exists
            if let itemId = favoriteStatus.itemId {
                self.existingItemId = itemId
            }
        } else {
            // Default heart button if no content yet
            let heartButton = UIBarButtonItem(image: UIImage(named: "heart-empty"), style: .plain, target: self, action: #selector(toggleFavoriteTapped))
            navigationItem.rightBarButtonItem = heartButton
        }
        
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadNativeAdIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Let the navigation controller delegate handle tab bar visibility
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
        // Configure main container view
        codeContentView.translatesAutoresizingMaskIntoConstraints = false
        codeContentView.backgroundColor = .white
        codeContentView.layer.cornerRadius = 12
        codeContentView.layer.borderWidth = 1
        codeContentView.layer.borderColor = UIColor.systemGray4.cgColor
        
        // Configure QR code image view
        qrCodeImageView.contentMode = .scaleAspectFit
        qrCodeImageView.translatesAutoresizingMaskIntoConstraints = false
        qrCodeImageView.backgroundColor = .white

        barcodeView.backgroundColor = .white
        barcodeView.translatesAutoresizingMaskIntoConstraints = false
        
        barcodeContentStackView.axis = .horizontal
        barcodeContentStackView.distribution = .fill
        barcodeContentStackView.alignment = .center
        barcodeContentStackView.spacing = 8
        barcodeContentStackView.translatesAutoresizingMaskIntoConstraints = false

        barCodeTypeImageView.contentMode = .scaleAspectFit
        barCodeTypeImageView.translatesAutoresizingMaskIntoConstraints = false

        barCodeTypeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        barCodeTypeTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        barCodeImageView.contentMode = .scaleAspectFit
        barCodeImageView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .textPrimary
        
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.textAlignment = .center
        descLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        descLabel.textColor = .appPrimary
        
        buttonsStackView.axis = .horizontal
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.spacing = 8
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        shareButton.configure(with: .primary(title: Strings.Label.share, image: UIImage(systemName: "square.and.arrow.up")))
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        
        saveButton.configure(with: .secondary(title: Strings.Label.save, image: UIImage(systemName: "square.and.arrow.down")))
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        nativeAdParentView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    private func setupConstraints() {
        // Add all views to the hierarchy first
        view.addSubview(codeContentView)
        codeContentView.addSubview(qrCodeImageView)
        codeContentView.addSubview(barcodeView)
        barcodeView.addSubview(barcodeContentStackView)
        barcodeView.addSubview(barCodeImageView)
        barcodeContentStackView.addArrangedSubview(barCodeTypeImageView)
        barcodeContentStackView.addArrangedSubview(barCodeTypeTitleLabel)
        view.addSubview(titleLabel)
        view.addSubview(descLabel)
        view.addSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(shareButton)
        buttonsStackView.addArrangedSubview(saveButton)
        view.addSubview(nativeAdParentView)
        
        // Main container constraints
        NSLayoutConstraint.activate([
            codeContentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            codeContentView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            codeContentView.heightAnchor.constraint(equalTo: codeContentView.widthAnchor),
            codeContentView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // QR code image view constraints
        NSLayoutConstraint.activate([
            qrCodeImageView.topAnchor.constraint(equalTo: codeContentView.topAnchor, constant: 8),
            qrCodeImageView.leadingAnchor.constraint(equalTo: codeContentView.leadingAnchor, constant: 8),
            qrCodeImageView.trailingAnchor.constraint(equalTo: codeContentView.trailingAnchor, constant: -8),
            qrCodeImageView.bottomAnchor.constraint(equalTo: codeContentView.bottomAnchor, constant: -8)
        ])
        
        // Barcode view constraints
        NSLayoutConstraint.activate([
            barcodeView.topAnchor.constraint(equalTo: codeContentView.topAnchor, constant: 16),
            barcodeView.leadingAnchor.constraint(equalTo: codeContentView.leadingAnchor, constant: 16),
            barcodeView.trailingAnchor.constraint(equalTo: codeContentView.trailingAnchor, constant: -16),
            barcodeView.bottomAnchor.constraint(equalTo: codeContentView.bottomAnchor, constant: -16)
        ])
        
        // Barcode content stack view constraints
        NSLayoutConstraint.activate([
            barcodeContentStackView.centerXAnchor.constraint(equalTo: barcodeView.centerXAnchor),
            barcodeContentStackView.heightAnchor.constraint(equalToConstant: 40),
            barcodeContentStackView.topAnchor.constraint(equalTo: barcodeView.topAnchor, constant: 8),
            barcodeContentStackView.widthAnchor.constraint(equalTo: barcodeView.widthAnchor, multiplier: 0.6),
            
            barCodeTypeImageView.heightAnchor.constraint(equalToConstant: 36),
            barCodeTypeImageView.widthAnchor.constraint(equalToConstant: 36),
            barCodeTypeTitleLabel.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        // Barcode image view constraints
        NSLayoutConstraint.activate([
            barCodeImageView.topAnchor.constraint(equalTo: barcodeContentStackView.bottomAnchor, constant: 16),
            barCodeImageView.leadingAnchor.constraint(equalTo: barcodeView.leadingAnchor, constant: 8),
            barCodeImageView.trailingAnchor.constraint(equalTo: barcodeView.trailingAnchor, constant: -8),
            barCodeImageView.bottomAnchor.constraint(equalTo: barcodeView.bottomAnchor, constant: -8)
        ])
        
        nativeAdHeightConstraint = nativeAdParentView.heightAnchor.constraint(equalToConstant: UIDevice().isSmallerDevice() ? 159 : 240)

        // Other UI elements constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: codeContentView.bottomAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: codeContentView.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            descLabel.centerXAnchor.constraint(equalTo: codeContentView.centerXAnchor),
            descLabel.heightAnchor.constraint(equalToConstant: 24),
            
            buttonsStackView.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 28),
            buttonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
            
            saveButton.heightAnchor.constraint(equalTo: buttonsStackView.heightAnchor),
            shareButton.heightAnchor.constraint(equalTo: buttonsStackView.heightAnchor),
            
            nativeAdHeightConstraint,
            nativeAdParentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
            nativeAdParentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
            nativeAdParentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -17)
        ])
    }
    
    private func setupActions() {
        let shareTapGesture = UITapGestureRecognizer(target: self, action: #selector(shareButtonTapped))
        let saveTapGesture = UITapGestureRecognizer(target: self, action: #selector(saveButtonTapped))

        shareButton.addGestureRecognizer(shareTapGesture)
        saveButton.addGestureRecognizer(saveTapGesture)
        
        print("[CodeGenerationResultViewController] Set up button actions")
    }
    
    // MARK: - Public Methods
    
    /// Set the QR code image and show QR code view
    func setQRCodeImage(_ image: UIImage) {
        // Set image and show QR code view
        qrCodeImageView.image = image
        qrCodeImageView.isHidden = false
        barcodeView.isHidden = true
        
        // Bring QR code image view to front
        codeContentView.bringSubviewToFront(qrCodeImageView)
    }
    
    /// Set the barcode image and show barcode view
    func setBarCodeImage(_ image: UIImage) {
        // Set image and show barcode view
        barCodeImageView.image = image
        barcodeView.isHidden = false
        qrCodeImageView.isHidden = true
        
        // Bring barcode view to front
        codeContentView.bringSubviewToFront(barcodeView)
    }
    
    /// Set the barcode type icon and title
    func setBarCodeType(icon: UIImage?, title: String) {
        barCodeTypeImageView.image = icon
        barCodeTypeTitleLabel.text = title
    }
    
    /// Set the title and description labels
    func setTitleAndDescription(title: String, description: String) {
        titleLabel.text = title
        descLabel.text = description
    }
    
    /// Set the save button action
    func setSaveAction(_ action: @escaping () -> Void) {
        saveAction = action
    }
    
    /// Set the share button action
    func setShareAction(_ action: @escaping () -> Void) {
        shareAction = action
    }
    
    /// Set the generated content for favorite status checking
    /// - Parameters:
    ///   - content: The generated content
    ///   - existingItemId: Optional existing item ID (if known)
    ///   - isFavorite: Whether the item is already favorited (if known)
    func setGeneratedContent(_ content: String, existingItemId: String? = nil, isFavorite: Bool? = nil) {
        self.generatedContent = content
        
        if let itemId = existingItemId {
            // Use the provided item ID and favorite status
            self.existingItemId = itemId
            
            // Update heart button based on provided favorite status
            if let isFavorite = isFavorite {
                let heartImageName = isFavorite ? "heart-fill" : "heart-empty"
                let heartImage = UIImage(named: heartImageName)
                
                // Create a new button with the updated heart image
                let heartButton = UIBarButtonItem(image: heartImage, style: .plain, target: self, action: #selector(toggleFavoriteTapped))
                
                // Set the tint color to red if favorited
                if isFavorite {
                    heartButton.tintColor = .systemRed
                }
                
                navigationItem.rightBarButtonItem = heartButton
                return
            }
        }
        
        // If no explicit ID/status provided, check if content exists in favorites
        let favoriteStatus = HistoryManager.shared.isContentFavorited(content)
        
        // Update heart button with correct state
        let heartImageName = favoriteStatus.isFavorite ? "heart-fill" : "heart-empty"
        let heartImage = UIImage(named: heartImageName)
        
        // Create a new button with the updated heart image
        let heartButton = UIBarButtonItem(image: heartImage, style: .plain, target: self, action: #selector(toggleFavoriteTapped))
        
        // Set the tint color to red if favorited
        if favoriteStatus.isFavorite {
            heartButton.tintColor = .systemRed
        }
        
        navigationItem.rightBarButtonItem = heartButton
        
        // Store the item ID if it exists
        if let itemId = favoriteStatus.itemId {
            self.existingItemId = itemId
        }
    }
    
    // MARK: - Actions
    @objc private func toggleFavoriteTapped() {
        var itemId: String
        
        if let existingId = existingItemId {
            // Use the existing item ID if we found one
            itemId = existingId
        } else {
            // Otherwise get the latest created history item
            let createdHistory = HistoryManager.shared.getCreatedHistory()
            guard let latestItem = createdHistory.first else { return }
            itemId = latestItem.id
            // Store this ID for future use
            existingItemId = itemId
        }
        
        let newFavoriteStatus = HistoryManager.shared.toggleFavorite(forItemWithId: itemId)
        let heartImageName = newFavoriteStatus ? "heart-fill" : "heart-empty"
        let heartImage = UIImage(named: heartImageName)
        
        // Create a new button with the updated heart image
        let heartButton = UIBarButtonItem(image: heartImage, style: .plain, target: self, action: #selector(toggleFavoriteTapped))
        
        // Set the tint color to red if favorited
        if newFavoriteStatus {
            heartButton.tintColor = .systemRed
        }
        
        navigationItem.rightBarButtonItem = heartButton
    }

    
    @objc private func shareButtonTapped() {
        shareAction?()
    }
    
    @objc private func saveButtonTapped() {
        // Present action sheet for save options
        let alert = UIAlertController(title: Strings.Label.saveCode, message: Strings.Label.chooseWhereToSave, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: Strings.Label.saveToGallery, style: .default, handler: { _ in
            self.saveImageToGallery()
        }))
        alert.addAction(UIAlertAction(title: Strings.Label.saveToFiles, style: .default, handler: { _ in
            self.saveImageToFiles()
        }))
        alert.addAction(UIAlertAction(title: Strings.Label.cancel, style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.saveButton
            popover.sourceRect = self.saveButton.bounds
        }
        present(alert, animated: true)
    }

    private func saveImageToGallery() {
        let image = !qrCodeImageView.isHidden ? qrCodeImageView.image : barCodeImageView.image
        guard let imageToSave = image else {
            let alert = UIAlertController(title: Strings.Label.error, message: Strings.Label.noImageToSave, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Strings.Label.ok, style: .default))
            present(alert, animated: true)
            return
        }
        PhotosManager.shared.save(image: imageToSave) { result in
            switch result {
            case .success:
                let alert = UIAlertController(title: "\(Strings.Label.saved)!", message: Strings.Label.imageSavedToLibrary, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: Strings.Label.ok, style: .default))
                self.present(alert, animated: true)
            case .failure(let error):
                let alert = UIAlertController(title: Strings.Label.error, message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: Strings.Label.ok, style: .default))
                self.present(alert, animated: true)
            }
        }
    }

    private func saveImageToFiles() {
        let image = !qrCodeImageView.isHidden ? qrCodeImageView.image : barCodeImageView.image
        guard let imageToSave = image else {
            let alert = UIAlertController(title: Strings.Label.error, message: Strings.Label.noImageToSave, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Strings.Label.ok, style: .default))
            present(alert, animated: true)
            return
        }
        PhotosManager.shared.saveToFiles(image: imageToSave, presenter: self) { result in
            print(result)
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
        nativeAdHeightConstraint.constant = UIDevice().isSmallerDevice() ? 159 : 240

        let nibName = UIDevice().isSmallerDevice() ? "NativeAdView" : "OnBoardingNativeAdView"
        let nibView = Bundle.main.loadNibNamed(nibName, owner: nil, options: nil)?.first
        guard let nativeAdView = nibView as? NativeAdView else { return }
        setAdView(nativeAdView)

        if UIDevice().isSmallerDevice() {
            nativeAdView.mediaView?.isHidden = true
            nativeAdView.mediaView?.removeFromSuperview()
        } else {
            (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
            nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        }

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
}
