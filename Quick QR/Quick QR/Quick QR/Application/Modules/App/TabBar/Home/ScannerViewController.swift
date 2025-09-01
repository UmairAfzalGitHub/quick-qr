//
//  ScannerViewController.swift
//  Quick QR
//
//  Created by Haider Rathore on 01/09/2025.
//

import UIKit
import AVFoundation

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
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
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        setupConstraints()
        openCamera()
        hideCenterQRImageView()
    }
    
    func setupUI() {
        view.addSubview(iapImage)
        view.addSubview(scannerFrameImageView)
        scannerFrameImageView.addSubview(qrTempImageView)
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
    
    func openCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.setupCamera()
                    } else {
                        self?.showPermissionAlert()
                    }
                }
            }
        case .denied, .restricted:
            showPermissionAlert()
        @unknown default:
            break
        }
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        
        // Input
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput) else { return }
        captureSession.addInput(videoInput)
        
        // Output
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr] // only QR codes
        }
        
        // Preview
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.layer.bounds
        if let previewLayer = previewLayer {
            view.layer.insertSublayer(previewLayer, at: 0)
        }
        
        captureSession.startRunning()
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
    
    // MARK: - QR Type Detection
    private func detectQRCodeType(from value: String) -> CodeTypeProtocol? {
        let raw = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = raw.lowercased()
        
        // Explicit formats
        if lower.hasPrefix("wifi:") { return QRCodeType.wifi }
        if lower.hasPrefix("tel:") || lower.hasPrefix("sms:") || lower.hasPrefix("telprompt:") {
            return QRCodeType.phone
        }
        if lower.hasPrefix("sms:") { return QRCodeType.text }
        if raw.contains("BEGIN:VCARD") || lower.contains("mecard:") { return QRCodeType.contact }
        if lower.hasPrefix("mailto:") || lower.hasPrefix("matmsg:") { return QRCodeType.email }
        if lower.hasPrefix("geo:") || lower.contains("maps.google.") || lower.contains("maps.apple.") { return QRCodeType.location }
        if raw.contains("BEGIN:VEVENT") || raw.contains("BEGIN:VCALENDAR") { return QRCodeType.events }
        
        // URL-based detection
        if let url = URL(string: raw), let scheme = url.scheme?.lowercased() {
            let host = (url.host ?? "").lowercased()
            
//            SocialQRCodeType.allCases.forEach { social in
//                for suffix in social.suffex ?? [] {
//                    if host.hasSuffix(suffix) {
//                        return social
//                    }
//                }
//            }
            // Social apps
            if scheme == "viber" ||  host.hasSuffix("vb.me") { return SocialQRCodeType.viber }
            if host.hasSuffix("tiktok.com") { return SocialQRCodeType.tiktok }
            if host.hasSuffix("instagram.com") { return SocialQRCodeType.instagram }
            if host.hasSuffix("facebook.com") || host == "fb.com" { return SocialQRCodeType.facebook }
            if host.hasSuffix("twitter.com") || host.hasSuffix("twitter") || host.hasSuffix("x.com") { return SocialQRCodeType.x }
            if host.hasSuffix("whatsapp.com") || host == "wa.me" { return SocialQRCodeType.whatsapp }
            if host.hasSuffix("youtube.com") || host == "youtu.be" { return SocialQRCodeType.youtube }
            if host.hasSuffix("spotify.com") { return SocialQRCodeType.spotify }
            
            // Any other valid URL treated as website
            if scheme == "http" || scheme == "https" { return QRCodeType.website }
        }
        
        // Fallback
        return QRCodeType.website
    }
    
    // MARK: - QR Detection Delegate
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              object.type == .qr,
              let qrValue = object.stringValue else { return }
        
        // Stop scanning once found
        captureSession?.stopRunning()
        
        // Handle the QR value
        let detected = detectQRCodeType(from: qrValue)
        let detectedTitle = (detected?.title ?? "QR Code")
        print("QR Code Detected [\(detectedTitle)]: \(qrValue)")
        
        let alert = UIAlertController(title: detectedTitle, message: qrValue, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.captureSession?.startRunning() // restart if needed
        })
        present(alert, animated: true)
    }
}
