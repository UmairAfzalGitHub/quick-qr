//
//  ScannerViewController.swift
//  Quick QR
//
//  Created by Haider Rathore on 01/09/2025.
//

import UIKit
import AVFoundation
import CoreImage
import GoogleMobileAds
import FirebaseAnalytics
import Vision
import ImageIO

class ScannerViewController: BaseViewController {
    
    // MARK: - Properties
    
    let scannerManager = CodeScannerManager()

    // MARK: - Batch Scan State
    private var isBatchMode = false
    private var batchResults: [BatchScanItem] = []

    // Focus animation view
    private let focusIndicator: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        view.layer.borderWidth = 2.0
        view.layer.borderColor = UIColor.yellow.cgColor
        view.backgroundColor = .clear
        // Square shape, no corner radius
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iapImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "iap-icon")
        image.isUserInteractionEnabled = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let scannerFrameImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "scanner-frame"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let qrTempImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "qr-temp-icon"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // Gallery scan button — dark semi-transparent bg for contrast on camera feed
    private let galleryButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let icon = UIImage(systemName: "photo.on.rectangle", withConfiguration: config)
        button.setImage(icon, for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityLabel = "Scan from gallery"
        return button
    }()

    // Batch mode toggle button — same dark style, turns appPrimary when active
    private let batchToggleButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let icon = UIImage(systemName: "square.stack.3d.up", withConfiguration: config)
        button.setImage(icon, for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityLabel = "Toggle batch scan mode"
        return button
    }()

    // Floating badge showing batch scan count
    private let batchBadge: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .appPrimary
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        button.layer.cornerRadius = 20
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0
        button.isHidden = true
        // Shadow for floating effect
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        button.layer.masksToBounds = false
        return button
    }()

    // Green flash overlay for batch scan feedback
    private let batchFlashView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.25)
        v.isUserInteractionEnabled = false
        v.alpha = 0
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // Frosted-glass scanning overlay shown while processing a gallery image
    private lazy var scanOverlay: UIView = {
        let overlay = UIView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.alpha = 0

        // Simple semi-transparent background (NOT frosted glass). 
        // Frosted glass (UIVisualEffectView) consumes 100% of the GPU on older devices, 
        // which was causing the scanning engine to crawl.
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        

        // Card
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        card.layer.cornerRadius = 20
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        overlay.addSubview(card)

        // Spinner
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .appPrimary
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        card.addSubview(spinner)

        // Label
        let label = UILabel()
        label.text = "Scanning..."
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.85)
        label.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(label)

        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
            card.widthAnchor.constraint(equalToConstant: 140),
            card.heightAnchor.constraint(equalToConstant: 110),

            spinner.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: card.centerYAnchor, constant: -12),

            label.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 10),
        ])
        return overlay
    }()
    
    // MARK: - Banner Properties
    var bannerView: BannerView!
    var bannerViewHeghtConstraint: NSLayoutConstraint!

    // Dedicated serial queue for scanning
    private let scanQueue = DispatchQueue(label: "com.quickqr.scanQueue", qos: .userInteractive)
    
    // Static engine hook to keep the Vision hardware "warm"
    private static let warmUpRequest = VNDetectBarcodesRequest()
    
    public static func preWarmEngines() {
        print("[GALLERY_SCAN] Pre-warming engines...")
        DispatchQueue.global(qos: .background).async {
            // A simple request and handler initialization keeps the framework and GPU kernels ready
            let request = VNDetectBarcodesRequest()
            let dummy = UIImage(systemName: "circle")?.cgImage
            if let cg = dummy {
                let handler = VNImageRequestHandler(cgImage: cg, options: [:])
                try? handler.perform([request])
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupUI()
        setupConstraints()
        // Configure scanner manager
        scannerManager.delegate = self
        scannerManager.previewContainer = view
        
        if IAPManager.shared.isUserSubscribed == false {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {[weak self] in
                let vc = IAPViewController()
                vc.isFromScannerFlow = true
                vc.modalPresentationStyle = .fullScreen
                self?.tabBarController?.present(vc, animated: true)
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupBanner(adId: RemoteConfigManager.shared.banner)
        super.bannerAdView = self.bannerView

        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        hideCenterQRImageView()
        // Pre-configure camera but don't start yet
        scannerManager.prepareCamera()
        Analytics.logEvent("Home screen", parameters: nil)

        // Sync batch badge when returning from BatchResultsViewController
        if isBatchMode {
            if batchResults.isEmpty {
                hideBatchBadge()
            } else {
                updateBatchBadge()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Add a delay before starting camera session to avoid configuration conflicts
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            // Start camera with highest priority after a delay
            self?.scannerManager.startCameraSession(true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        // Completely stop camera when leaving to avoid privacy indicator
        scannerManager.stopCameraSession()
    }
    
    override func handleSubscriptionPurchased() {
        super.handleSubscriptionPurchased()
        bannerViewHeghtConstraint.constant = 0
        bannerView.isHidden = true
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func setupUI() {
        view.addSubview(scannerFrameImageView)
        scannerFrameImageView.addSubview(qrTempImageView)
        view.addSubview(focusIndicator)

        bannerView = BannerView()
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        // Create banner view height constraint
        bannerViewHeghtConstraint = bannerView.heightAnchor.constraint(equalToConstant: 60)

        // Add iapImage last so it appears on top
        view.addSubview(iapImage)

        // Add gallery and batch buttons at the top
        view.addSubview(galleryButton)
        galleryButton.addTarget(self, action: #selector(galleryButtonTapped), for: .touchUpInside)
        view.addSubview(batchToggleButton)
        batchToggleButton.addTarget(self, action: #selector(batchModeToggled), for: .touchUpInside)

        // Add batch flash overlay (covers scanner frame area)
        view.addSubview(batchFlashView)

        // Add batch badge
        view.addSubview(batchBadge)
        batchBadge.addTarget(self, action: #selector(batchBadgeTapped), for: .touchUpInside)

        // Scanning overlay (hidden by default, shown during gallery processing)
        view.addSubview(scanOverlay)
        NSLayoutConstraint.activate([
            scanOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scanOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scanOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            scanOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        // Add tap gesture recognizer for focus
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)

        // Add tap gesture recognizer for IAP image
        let iapTapGesture = UITapGestureRecognizer(target: self, action: #selector(openIAPTapped))
        iapImage.addGestureRecognizer(iapTapGesture)
    }
    
    func setupConstraints() {
        // Common constraints for UI elements
        let multiplier: CGFloat = UIDevice().isSmallDevice || UIDevice().isProDevice() ? 0.6 : 0.8

        var constraints = [
            iapImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            iapImage.heightAnchor.constraint(equalToConstant: 31),
            iapImage.widthAnchor.constraint(equalToConstant: 77),
            scannerFrameImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scannerFrameImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: multiplier),
            scannerFrameImageView.heightAnchor.constraint(equalTo: scannerFrameImageView.widthAnchor),

            qrTempImageView.topAnchor.constraint(equalTo: scannerFrameImageView.topAnchor, constant: 4),
            qrTempImageView.leadingAnchor.constraint(equalTo: scannerFrameImageView.leadingAnchor, constant: 4),
            qrTempImageView.trailingAnchor.constraint(equalTo: scannerFrameImageView.trailingAnchor, constant: -4),
            qrTempImageView.bottomAnchor.constraint(equalTo: scannerFrameImageView.bottomAnchor, constant: -4),
            bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannerViewHeghtConstraint!,

            // Gallery button — top-left
            galleryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            galleryButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
            galleryButton.widthAnchor.constraint(equalToConstant: 40),
            galleryButton.heightAnchor.constraint(equalToConstant: 40),

            // Batch toggle button — next to gallery
            batchToggleButton.leadingAnchor.constraint(equalTo: galleryButton.trailingAnchor, constant: 10),
            batchToggleButton.centerYAnchor.constraint(equalTo: galleryButton.centerYAnchor),
            batchToggleButton.widthAnchor.constraint(equalToConstant: 40),
            batchToggleButton.heightAnchor.constraint(equalToConstant: 40),

            // Green flash overlay — covering the scanner frame
            batchFlashView.topAnchor.constraint(equalTo: scannerFrameImageView.topAnchor),
            batchFlashView.leadingAnchor.constraint(equalTo: scannerFrameImageView.leadingAnchor),
            batchFlashView.trailingAnchor.constraint(equalTo: scannerFrameImageView.trailingAnchor),
            batchFlashView.bottomAnchor.constraint(equalTo: scannerFrameImageView.bottomAnchor),

            // Batch badge — below scanner frame, above banner
            batchBadge.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            batchBadge.topAnchor.constraint(equalTo: scannerFrameImageView.bottomAnchor, constant: 16),
            batchBadge.heightAnchor.constraint(equalToConstant: 40),
        ]

        // Position the ad based on the showAdAtBottom flag
        if RemoteConfigManager.shared.showScannerNativeAtBottom {
            // Ad at bottom, scanner in center, pro button at top
            constraints.append(contentsOf: [
                iapImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
                scannerFrameImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            ])
        } else {
            // Ad at top, pro button below ad with 12px padding, scanner below pro button
            constraints.append(contentsOf: [
                bannerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                iapImage.topAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: 12),
                scannerFrameImageView.topAnchor.constraint(equalTo: iapImage.bottomAnchor, constant: 20)
            ])
        }

        NSLayoutConstraint.activate(constraints)
    }
    
    func hideCenterQRImageView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.4, animations: {
                self.qrTempImageView.alpha = 0
            }) { _ in
                self.qrTempImageView.isHidden = true
            }
        }
    }
    
    // MARK: - Tap to Focus
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: view)
        
        // Convert touch point to camera's coordinate space
        let focusPoint = scannerManager.convertToPointOfInterest(touchPoint: touchPoint)
        
        // Set focus at point
        scannerManager.focusAtPoint(focusPoint)
        
        // Show focus animation
        showFocusAnimation(at: touchPoint)
    }
    
    private func showFocusAnimation(at point: CGPoint) {
        // Position focus indicator at tap point
        focusIndicator.center = point
        
        // Reset any ongoing animations
        focusIndicator.layer.removeAllAnimations()
        
        // Make visible and animate
        focusIndicator.alpha = 1.0
        focusIndicator.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        
        // Animate focus indicator
        UIView.animate(withDuration: 0.3, animations: {
            self.focusIndicator.transform = .identity
        }) { _ in
            UIView.animate(withDuration: 0.2, delay: 0.5, options: [], animations: {
                self.focusIndicator.alpha = 0
            })
        }
    }
    
    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: Strings.Label.cameraAccessNeeded,
            message: Strings.Label.pleaseEnableCamera,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Strings.Label.cancel, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: Strings.Label.settings, style: .default, handler: { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - IAP
    @objc private func openIAPTapped() {
        let vc = IAPViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    // MARK: - Batch Mode

    @objc private func batchModeToggled() {
        isBatchMode.toggle()

        // Animate button press
        UIView.animate(withDuration: 0.1, animations: {
            self.batchToggleButton.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.batchToggleButton.transform = .identity
            }
        }

        // Update button appearance
        UIView.animate(withDuration: 0.25) {
            if self.isBatchMode {
                self.batchToggleButton.backgroundColor = .appPrimary
                self.batchToggleButton.tintColor = .white
            } else {
                self.batchToggleButton.backgroundColor = UIColor.black.withAlphaComponent(0.55)
                self.batchToggleButton.tintColor = .white
            }
        }

        if isBatchMode {
            // Resume camera if it was paused (from a previous single-scan result)
            scannerManager.resumeCameraFeed()
            // Show badge if we already have items
            if !batchResults.isEmpty {
                updateBatchBadge()
            }
        } else {
            // Turning off batch mode: hide badge, keep results
            hideBatchBadge()
        }

        FeedbackManager.shared.provideScanFeedback()
    }

    @objc private func batchBadgeTapped() {
        let batchVC = BatchResultsViewController()
        batchVC.batchItems = batchResults
        batchVC.onClearAll = { [weak self] in
            self?.batchResults.removeAll()
            self?.hideBatchBadge()
        }
        navigationController?.pushViewController(batchVC, animated: true)
    }

    private func updateBatchBadge() {
        let count = batchResults.count
        batchBadge.setTitle("\(count) Scanned — View All ›", for: .normal)

        if batchBadge.isHidden {
            batchBadge.isHidden = false
            batchBadge.transform = CGAffineTransform(translationX: 0, y: 60)
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
                self.batchBadge.alpha = 1
                self.batchBadge.transform = .identity
            }
        } else {
            // Bounce animation on count update
            UIView.animate(withDuration: 0.15, animations: {
                self.batchBadge.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
            }) { _ in
                UIView.animate(withDuration: 0.15) {
                    self.batchBadge.transform = .identity
                }
            }
        }
    }

    private func hideBatchBadge() {
        UIView.animate(withDuration: 0.3, animations: {
            self.batchBadge.alpha = 0
            self.batchBadge.transform = CGAffineTransform(translationX: 0, y: 60)
        }) { _ in
            self.batchBadge.isHidden = true
            self.batchBadge.transform = .identity
        }
    }

    private func playBatchFlash() {
        batchFlashView.alpha = 0.6
        UIView.animate(withDuration: 0.35) {
            self.batchFlashView.alpha = 0
        }
    }

    // MARK: - Gallery Scanning
    @objc private func galleryButtonTapped() {
        print("[GALLERY_SCAN] Gallery button tapped")
        
        // PAUSE CAMERA: Free up GPU/NPU for the image scan
        scannerManager.pauseCameraFeed()
        
        // Animate button press
        UIView.animate(withDuration: 0.1, animations: {
            self.galleryButton.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.galleryButton.transform = .identity
            }
        }

        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = false
        present(picker, animated: true)
    }

    /// Scan a QR / barcode from a file URL using CGImageSource + Vision.
    /// Uses `CGImageSourceCreateThumbnailAtIndex` to downsample directly from the
    /// compressed file — never decodes the full-resolution image into memory,
    /// making it orders of magnitude faster than going through UIImage.
    /// Scan a QR / barcode from a file URL using CGImageSource (Downsampled) + Vision.
    private func scanCodeFromFile(at fileURL: URL, completion: @escaping (String?, AVMetadataObject.ObjectType) -> Void) {
        let startTime = CFAbsoluteTimeGetCurrent()
        print("[GALLERY_SCAN] Starting optimized scan for: \(fileURL.lastPathComponent)")
        
        scanQueue.async { [weak self] in
            guard let self else { return }

            // 1. DOWNSAMPLE FIRST: This is critical. Converting to a 512px thumbnail 
            // takes ~10ms and avoids loading a massive 12MP-48MP photo into the GPU.
            guard let source = CGImageSourceCreateWithURL(fileURL as CFURL, nil),
                  let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, [
                      kCGImageSourceCreateThumbnailFromImageAlways: true,
                      kCGImageSourceCreateThumbnailWithTransform: true,
                      kCGImageSourceThumbnailMaxPixelSize: 512
                  ] as CFDictionary) else {
                DispatchQueue.main.async { completion(nil, .qr) }
                return
            }
            
            print("[GALLERY_SCAN] Thumbnail prepared (512px) in: \(CFAbsoluteTimeGetCurrent() - startTime)s")

            // 2. Scan with Vision
            let request = VNDetectBarcodesRequest()
            if #available(iOS 16.0, *) {
                request.revision = VNDetectBarcodesRequestRevision3
            } else {
                request.revision = VNDetectBarcodesRequestRevision1
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
            
            do {
                try handler.perform([request])
                let result = (request.results as? [VNBarcodeObservation])?.first
                print("[GALLERY_SCAN] Vision finished in: \(CFAbsoluteTimeGetCurrent() - startTime)s")
                
                DispatchQueue.main.async {
                    completion(result?.payloadStringValue, 
                               self.visionSymbologyToObjectType(result?.symbology ?? .qr))
                }
            } catch {
                print("[GALLERY_SCAN] Scan failed: \(error)")
                DispatchQueue.main.async { completion(nil, .qr) }
            }
        }
    }

    /// Fallback scanner when we already have a CGImage (e.g. from UIImagePickerController's .originalImage).
    private func scanCodeFromCGImage(_ cgImage: CGImage, completion: @escaping (String?, AVMetadataObject.ObjectType) -> Void) {
        let startTime = CFAbsoluteTimeGetCurrent()
        print("[GALLERY_SCAN] Starting scanCodeFromCGImage")
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self else { return }

            let request = VNDetectBarcodesRequest()
            request.symbologies = [.qr, .ean8, .ean13, .pdf417, .aztec,
                                   .code39, .code93, .code128, .dataMatrix,
                                   .i2of5, .upce, .itf14]
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])

            let result = (request.results as? [VNBarcodeObservation])?.first
            print("[GALLERY_SCAN] Vision detection finished in: \(CFAbsoluteTimeGetCurrent() - startTime)s")
            
            DispatchQueue.main.async {
                completion(result?.payloadStringValue,
                           self.visionSymbologyToObjectType(result?.symbology ?? .qr))
            }
        }
    }

    /// Map Vision symbology to AVMetadataObject.ObjectType so we reuse the existing result screen.
    private func visionSymbologyToObjectType(_ symbology: VNBarcodeSymbology) -> AVMetadataObject.ObjectType {
        switch symbology {
        case .qr:              return .qr
        case .ean8:            return .ean8
        case .ean13:           return .ean13
        case .pdf417:          return .pdf417
        case .aztec:           return .aztec
        case .code39:          return .code39
        case .code93:          return .code93
        case .code128:         return .code128
        case .dataMatrix:      return .dataMatrix
        case .i2of5:           return .interleaved2of5
        case .upce:            return .upce
        case .itf14:           return .itf14
        default:               return .qr
        }
    }

    /// Show an alert when no QR / barcode is found in the selected photo.
    private func showNoCodeFoundAlert() {
        // Resume camera if we fail
        scannerManager.resumeCameraFeed()
        
        let alert = UIAlertController(
            title: "No Code Found",
            message: "We couldn't detect a QR code or barcode in the selected photo. Please try a clearer image.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Strings.Label.ok, style: .default))
        present(alert, animated: true)
    }
}

// MARK: - CodeScannerDelegate

extension ScannerViewController: CodeScannerDelegate {
    
    func scannerDidDetectBarcode(value: String, type: AVMetadataObject.ObjectType, title: String) {
        // ───── BATCH MODE ─────
        if isBatchMode {
            // Ignore duplicates
            if batchResults.contains(where: { $0.value == value }) {
                // Still resume camera so it keeps scanning
                scannerManager.resumeCameraFeed()
                return
            }

            let scanResult = ScanDataParser.parse(data: value, symbology: type)
            let item = BatchScanItem(value: value, type: type, scanResult: scanResult, timestamp: Date())
            batchResults.append(item)

            // Visual + haptic feedback
            FeedbackManager.shared.provideScanFeedback()
            playBatchFlash()
            updateBatchBadge()

            // Resume camera immediately to keep scanning
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.scannerManager.resumeCameraFeed()
            }
            return
        }

        // ───── SINGLE SCAN MODE (existing behavior) ─────
        // Pause camera feed while showing scan result
        scannerManager.pauseCameraFeed()
        
        // Log the detected code
        if type == .qr {
            if let detected = detectQRCodeType(from: value) {
                print("QR Code Detected [\(detected.title)]: \(value)")
            } else {
                print("QR Code Detected: \(value)")
            }
        } else {
            print("\(title) Detected: \(value)")
        }
        
        navigateToResultScreen(value: value, type: type)
    }
    
    func navigateToResultScreen(value: String, type: AVMetadataObject.ObjectType) {
        // Create and push the scan result view controller
        let resultVC = ScanResultViewController(scannedData: value, metadataObjectType: type)
        
        // Set up a navigation controller if needed
        if navigationController == nil {
            // If we're not in a navigation controller, wrap in one
            let navController = UINavigationController(rootViewController: resultVC)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
        } else {
            // Push to existing navigation controller
            navigationController?.pushViewController(resultVC, animated: true)
        }
    }
    
    func scannerDidUpdatePermission(granted: Bool) {
        if granted {
            // On first grant, start the camera shortly after to avoid starting
            // while the capture session is still in beginConfiguration/commitConfiguration.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.scannerManager.startCameraSession(true)
            }
        } else {
            showPermissionAlert()
        }
    }
    
    // MARK: - QR Type Detection Helper
    
    private func detectQRCodeType(from value: String) -> CodeTypeProtocol? {
        let raw = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = raw.lowercased()
        let url = URL(string: raw)

        // Short-circuit: SMS/SMSTO should always be Text
        if lower.hasPrefix("sms:") || lower.hasPrefix("smsto:") {
            return QRCodeType.text
        }

        // 1) Social first
        for social in SocialQRCodeType.allCases {
            if matches(social, raw: raw, lower: lower, url: url) { return social }
        }

        // 2) QR types with priority so Location wins over Website
        let priority: [QRCodeType] = [.wifi, .phone, .contact, .email, .location, .events, .website, .text]
        for type in priority {
            if matches(type, raw: raw, lower: lower, url: url) { return type }
        }

        // 3) Fallback
        return QRCodeType.text
    }
    
    private func matches(_ type: CodeTypeProtocol, raw: String, lower: String, url: URL?) -> Bool {
        // Normalize rule lists to lowercase to ensure case-insensitive matching
        let prefixes = type.prefixes.map { $0.lowercased() }
        let substrings = type.contains.map { $0.lowercased() }
        let schemes = type.schemes.map { $0.lowercased() }
        let suffices = type.suffex.map { $0.lowercased() }

        // prefix match
        if !prefixes.isEmpty && prefixes.contains(where: { lower.hasPrefix($0) }) { return true }
        // substring match
        if !substrings.isEmpty && substrings.contains(where: { lower.contains($0) }) { return true }
        // url-based matches
        if let url = url {
            let scheme = url.scheme?.lowercased() ?? ""
            let host = (url.host ?? "").lowercased()
            if !schemes.isEmpty && schemes.contains(scheme) { return true }
            if !suffices.isEmpty && suffices.contains(where: { host.hasSuffix($0) }) { return true }
        }
        return false
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ScannerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let selectionTime = CFAbsoluteTimeGetCurrent()
        print("[GALLERY_SCAN] imagePickerController didFinishPickingMediaWithInfo")

        picker.dismiss(animated: true) { [weak self] in
            guard let self else { return }

            // Show the overlay immediately
            self.showScanOverlay()

            if let imageURL = info[.imageURL] as? URL {
                // PATH 1: Optimized direct-from-URL scan
                self.processSelectedImageURL(imageURL, selectionTime: selectionTime)
            } else if let image = info[.originalImage] as? UIImage {
                // PATH 2: Fallback to manual UIImage scan
                self.processSelectedUIImage(image, selectionTime: selectionTime)
            } else {
                self.hideScanOverlay()
                self.showNoCodeFoundAlert()
            }
        }
    }

    private func processSelectedImageURL(_ url: URL, selectionTime: CFAbsoluteTime) {
        print("[GALLERY_SCAN] Processing via URL: \(url.lastPathComponent)")
        self.scanCodeFromFile(at: url) { [weak self] value, objectType in
            guard let self else { return }
            self.hideScanOverlay()

            guard let value, !value.isEmpty else {
                self.showNoCodeFoundAlert()
                return
            }

            print("[GALLERY_SCAN] Success! Total time: \(CFAbsoluteTimeGetCurrent() - selectionTime)s")
            self.handleGalleryScanResult(value: value, type: objectType)
        }
    }

    private func processSelectedUIImage(_ image: UIImage, selectionTime: CFAbsoluteTime) {
        print("[GALLERY_SCAN] Processing via UIImage fallback")
        guard let cgImage = image.cgImage else {
            self.hideScanOverlay()
            self.showNoCodeFoundAlert()
            return
        }

        self.scanCodeFromCGImage(cgImage) { [weak self] value, objectType in
            guard let self else { return }
            self.hideScanOverlay()

            guard let value, !value.isEmpty else {
                self.showNoCodeFoundAlert()
                return
            }

            print("[GALLERY_SCAN] Success! Total time: \(CFAbsoluteTimeGetCurrent() - selectionTime)s")
            self.handleGalleryScanResult(value: value, type: objectType)
        }
    }

    /// Routes a gallery scan result to either the batch list or the single-result screen.
    private func handleGalleryScanResult(value: String, type: AVMetadataObject.ObjectType) {
        FeedbackManager.shared.provideScanFeedback()

        if isBatchMode {
            // Add to batch (skip duplicates)
            if !batchResults.contains(where: { $0.value == value }) {
                let scanResult = ScanDataParser.parse(data: value, symbology: type)
                let item = BatchScanItem(value: value, type: type, scanResult: scanResult, timestamp: Date())
                batchResults.append(item)
                playBatchFlash()
                updateBatchBadge()
            }
            // Resume camera for continued scanning
            scannerManager.resumeCameraFeed()
        } else {
            navigateToResultScreen(value: value, type: type)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) { [weak self] in
            // Resume camera if user cancelled selection
            self?.scannerManager.resumeCameraFeed()
        }
    }

    private func showScanOverlay() {
        view.bringSubviewToFront(scanOverlay)
        UIView.animate(withDuration: 0.2) { self.scanOverlay.alpha = 1 }
    }

    private func hideScanOverlay() {
        UIView.animate(withDuration: 0.2) { self.scanOverlay.alpha = 0 }
    }
}
