//
//  ScannerViewController.swift
//  Quick QR
//
//  Created by Haider Rathore on 01/09/2025.
//

import UIKit
import AVFoundation
import CoreImage

class ScannerViewController: UIViewController {
    
    // MARK: - Properties
    
    private let scannerManager = CodeScannerManager()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        setupConstraints()
        hideCenterQRImageView()
        
        // Configure scanner manager
        scannerManager.delegate = self
        scannerManager.previewContainer = view
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Pre-configure camera but don't start yet
        scannerManager.prepareCamera()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Start camera with highest priority
        scannerManager.startCameraSession(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Completely stop camera when leaving to avoid privacy indicator
        scannerManager.stopCameraSession()
    }
    
    func setupUI() {
        view.addSubview(iapImage)
        view.addSubview(scannerFrameImageView)
        scannerFrameImageView.addSubview(qrTempImageView)
        view.addSubview(focusIndicator)
        
        // Add tap gesture recognizer for focus
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            iapImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            iapImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            iapImage.heightAnchor.constraint(equalToConstant: 31),
            iapImage.widthAnchor.constraint(equalToConstant: 77),
            
            scannerFrameImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            scannerFrameImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scannerFrameImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            scannerFrameImageView.heightAnchor.constraint(equalTo: scannerFrameImageView.widthAnchor),
            
            qrTempImageView.topAnchor.constraint(equalTo: scannerFrameImageView.topAnchor, constant: 4),
            qrTempImageView.leadingAnchor.constraint(equalTo: scannerFrameImageView.leadingAnchor, constant: 4),
            qrTempImageView.trailingAnchor.constraint(equalTo: scannerFrameImageView.trailingAnchor, constant: -4),
            qrTempImageView.bottomAnchor.constraint(equalTo: scannerFrameImageView.bottomAnchor, constant: -4)
        ])
    }
    
    func hideCenterQRImageView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.5, animations: {
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
            title: "Camera Access Needed",
            message: "Please enable camera access in Settings to scan QR codes.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - CodeScannerDelegate

extension ScannerViewController: CodeScannerDelegate {
    
    func scannerDidDetectBarcode(value: String, type: AVMetadataObject.ObjectType, title: String) {
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
        
        // Create and present the scan result view controller
        let resultVC = ScanResultViewController(scannedData: value, metadataObjectType: type)
        resultVC.modalPresentationStyle = .fullScreen
        resultVC.dismissHandler = { [weak self] in
            // Resume camera feed when the result view is dismissed
            self?.scannerManager.resumeCameraFeed()
        }
        
        present(resultVC, animated: true)
    }
    
    func scannerDidUpdatePermission(granted: Bool) {
        if !granted {
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
