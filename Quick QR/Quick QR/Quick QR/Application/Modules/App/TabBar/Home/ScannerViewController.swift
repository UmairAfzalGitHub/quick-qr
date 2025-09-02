//
//  ScannerViewController.swift
//  Quick QR
//
//  Created by Haider Rathore on 01/09/2025.
//

import UIKit
import AVFoundation

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    // MARK: - Camera Session States
    private enum CameraState {
        case setup     // Initial setup
        case ready     // Ready but not running
        case running   // Actively capturing
        case paused    // Temporarily paused
    }
    
    private var cameraState: CameraState = .setup
    
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
        hideCenterQRImageView()
        
        // Register for app lifecycle notifications
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Make sure preview layer is visible
        if let previewLayer = previewLayer {
            previewLayer.opacity = 1.0
            if previewLayer.superlayer == nil {
                view.layer.insertSublayer(previewLayer, at: 0)
            }
        }
        
        // Pre-configure camera but don't start yet
        prepareCamera()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Start camera with highest priority
        startCameraSession(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Completely stop camera when leaving to avoid privacy indicator
        stopCameraSession()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    func prepareCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // Camera already set up in viewDidLoad
            if captureSession == nil {
                setupCamera()
            }
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
        // Only setup once
        if captureSession != nil {
            return
        }
        
        // Initialize session object
        let session = AVCaptureSession()
        self.captureSession = session
        
        // Create preview layer immediately to avoid white flash
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = self.view.layer.bounds
        previewLayer.backgroundColor = UIColor.black.cgColor
        self.previewLayer = previewLayer
        self.view.layer.insertSublayer(previewLayer, at: 0)
        
        // Configure camera session on background thread with highest priority
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            
            // Begin configuration
            session.beginConfiguration()
            
            // Input
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
                  let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
                  session.canAddInput(videoInput) else { return }
            session.addInput(videoInput)
            
            // Output
            let metadataOutput = AVCaptureMetadataOutput()
            if session.canAddOutput(metadataOutput) {
                session.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.qr] // only QR codes
            }
            
            // Commit configuration
            session.commitConfiguration()
            
            // Mark as ready but don't start yet
            self.cameraState = .ready
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
    
    // MARK: - QR Type Detection
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
    
    // MARK: - QR Detection Delegate
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              object.type == .qr,
              let qrValue = object.stringValue else { return }
        
        // Pause camera feed while showing alert
        pauseCameraFeed()
        
        // Handle the QR value
        let detected = detectQRCodeType(from: qrValue)
        let detectedTitle = (detected?.title ?? "QR Code")
        print("QR Code Detected [\(detectedTitle)]: \(qrValue)")
        
        let alert = UIAlertController(title: detectedTitle, message: qrValue, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.resumeCameraFeed() // resume camera feed
        })
        present(alert, animated: true)
    }
    
    // MARK: - Camera Session Management
    
    @objc private func appDidEnterBackground() {
        // Fully stop the session when app goes to background to save resources
        if cameraState == .running || cameraState == .paused {
            stopCameraSession()
        }
    }
    
    @objc private func appWillEnterForeground() {
        // Restart the session when app comes to foreground if we're visible
        if self.isViewVisible() && (cameraState == .ready || cameraState == .paused) {
            startCameraSession(true)
        }
    }
    
    private func isViewVisible() -> Bool {
        // Check if view is in window hierarchy and not hidden
        return self.isViewLoaded && self.view.window != nil
    }
    
    private func startCameraSession(_ highPriority: Bool = false) {
        let qos: DispatchQoS.QoSClass = highPriority ? .userInteractive : .userInitiated
        
        // Start on high priority thread
        DispatchQueue.global(qos: qos).async { [weak self] in
            guard let self = self, let captureSession = self.captureSession, !captureSession.isRunning else { return }
            
            // Start the session
            captureSession.startRunning()
            
            // Update state
            DispatchQueue.main.async {
                self.cameraState = .running
            }
        }
    }
    
    private func stopCameraSession() {
        // Completely stop the session (for app background)
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self, let captureSession = self.captureSession, captureSession.isRunning else { return }
            
            // Stop the session
            captureSession.stopRunning()
            
            // Update state
            DispatchQueue.main.async {
                self.cameraState = .ready
            }
        }
    }
    
    private func pauseCameraFeed() {
        // Stop the camera session when showing alert
        stopCameraSession()
    }
    
    private func resumeCameraFeed() {
        // Resume camera with high priority
        startCameraSession(true)
    }
}
