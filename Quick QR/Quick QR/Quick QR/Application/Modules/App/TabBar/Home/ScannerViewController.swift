//
//  ScannerViewController.swift
//  Quick QR
//
//  Created by Haider Rathore on 01/09/2025.
//

import UIKit
import AVFoundation

class ScannerViewController: UIViewController {
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else { return }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.layer.bounds
        if let previewLayer = previewLayer {
            view.layer.insertSublayer(previewLayer, at: 0) // show behind UI
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
}
