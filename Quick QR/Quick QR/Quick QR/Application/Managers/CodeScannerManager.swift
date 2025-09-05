//
//  CodeScannerManager.swift
//  Quick QR
//
//  Created by Umair Afzal on 03/09/2025.
//

import UIKit
import AVFoundation
import CoreImage

// MARK: - Scanner Delegate Protocol

protocol CodeScannerDelegate: AnyObject {
    /// Called when a barcode is detected
    func scannerDidDetectBarcode(value: String, type: AVMetadataObject.ObjectType, title: String)
    
    /// Called when camera permission status changes
    func scannerDidUpdatePermission(granted: Bool)
    
    /// Called when camera session state changes
    func scannerDidUpdateState(_ state: CodeScannerManager.CameraState)
}

// Optional protocol methods
extension CodeScannerDelegate {
    func scannerDidUpdatePermission(granted: Bool) {}
    func scannerDidUpdateState(_ state: CodeScannerManager.CameraState) {}
}

class CodeScannerManager: NSObject {
    
    // MARK: - Camera Session States
    enum CameraState {
        case setup     // Initial setup
        case ready     // Ready but not running
        case running   // Actively capturing
        case paused    // Temporarily paused
        case cooldown  // Temporary cooldown after detection
    }
    
    // MARK: - Properties
    
    weak var delegate: CodeScannerDelegate?
    weak var previewContainer: UIView?
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    // Debounce properties
    private var lastScannedValue: String? = nil
    private var cooldownTimer: Timer? = nil
    private var cooldownDuration: TimeInterval = 1.5 // Seconds to wait before allowing another scan
    
    private var cameraState: CameraState = .setup {
        didSet {
            delegate?.scannerDidUpdateState(cameraState)
        }
    }
    
    // MARK: - Initialization
    
    /// Initialize with a view container for the camera preview
    init(previewContainer: UIView? = nil, delegate: CodeScannerDelegate? = nil) {
        self.previewContainer = previewContainer
        self.delegate = delegate
        super.init()
        
        // Register for app lifecycle notifications
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public Methods
    
    /// Focus camera at a specific point in the preview
    /// - Parameter point: Point in the preview layer's coordinate space (0,0 to 1,1)
    func focusAtPoint(_ point: CGPoint) {
        guard let device = getCaptureDevice() else { return }
        
        do {
            try device.lockForConfiguration()
            
            // Check if device supports focus point of interest
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = point
                device.focusMode = .autoFocus
            }
            
            // Check if device supports exposure point of interest
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = point
                device.exposureMode = .autoExpose
            }
            
            device.unlockForConfiguration()
        } catch {
            print("Error setting focus point: \(error.localizedDescription)")
        }
    }
    
    /// Convert a touch point in the view to the camera's coordinate space
    /// - Parameter touchPoint: Point in the view's coordinate space
    /// - Returns: Normalized point in camera coordinate space (0,0 to 1,1)
    func convertToPointOfInterest(touchPoint: CGPoint) -> CGPoint {
        guard let previewLayer = previewLayer else {
            return CGPoint(x: 0.5, y: 0.5) // Default to center
        }
        
        // Convert point from view to camera coordinates
        return previewLayer.captureDevicePointConverted(fromLayerPoint: touchPoint)
    }
    
    /// Get the current capture device
    private func getCaptureDevice() -> AVCaptureDevice? {
        guard let captureSession = captureSession else { return nil }
        
        // Find video input
        let inputs = captureSession.inputs.compactMap { $0 as? AVCaptureDeviceInput }
        let videoInput = inputs.first { $0.device.hasMediaType(.video) }
        return videoInput?.device
    }
    
    /// Prepare the camera for use
    func prepareCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // Camera already authorized
            if captureSession == nil {
                setupCamera()
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.delegate?.scannerDidUpdatePermission(granted: granted)
                    if granted {
                        self?.setupCamera()
                    }
                }
            }
        case .denied, .restricted:
            delegate?.scannerDidUpdatePermission(granted: false)
        @unknown default:
            break
        }
    }
    
    /// Start the camera session with optional high priority
    func startCameraSession(_ highPriority: Bool = false) {
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
    
    /// Stop the camera session
    func stopCameraSession() {
        // Completely stop the session
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
    
    /// Pause the camera feed (stops the session)
    func pauseCameraFeed() {
        stopCameraSession()
    }
    
    /// Resume the camera feed with high priority
    func resumeCameraFeed() {
        startCameraSession(true)
    }
    
    /// Update the preview container view
    func updatePreviewContainer(_ container: UIView) {
        self.previewContainer = container
        
        // Update preview layer frame if it exists
        if let previewLayer = previewLayer, let container = previewContainer {
            previewLayer.frame = container.layer.bounds
            
            // Add to container if not already added
            if previewLayer.superlayer == nil {
                container.layer.insertSublayer(previewLayer, at: 0)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupCamera() {
        // Only setup once
        if captureSession != nil {
            return
        }
        
        // Initialize session object
        let session = AVCaptureSession()
        self.captureSession = session
        
        // Create preview layer immediately to avoid white flash
        if let container = previewContainer {
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = container.layer.bounds
            previewLayer.backgroundColor = UIColor.black.cgColor
            self.previewLayer = previewLayer
            container.layer.insertSublayer(previewLayer, at: 0)
        }
        
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
                
                // Support all barcode types
                metadataOutput.metadataObjectTypes = [
                    .qr,               // QR Code
                    .ean8,             // EAN-8
                    .ean13,            // EAN-13
                    .pdf417,           // PDF417
                    .aztec,            // Aztec
                    .code39,           // Code 39
                    .code93,           // Code 93
                    .code128,          // Code 128
                    .dataMatrix,       // Data Matrix
                    .interleaved2of5,  // ITF
                    .upce,             // UPC-E
                    .itf14             // ITF-14 (similar to UPC-A)
                ]
            }
            
            // Commit configuration
            session.commitConfiguration()
            
            // Mark as ready but don't start yet
            DispatchQueue.main.async {
                self.cameraState = .ready
            }
        }
    }
    
    // MARK: - App Lifecycle
    
    @objc private func appDidEnterBackground() {
        // Fully stop the session when app goes to background to save resources
        if cameraState == .running || cameraState == .paused {
            stopCameraSession()
        }
    }
    
    @objc private func appWillEnterForeground() {
        // Restart the session when app comes to foreground if we're visible
        if isPreviewVisible() && (cameraState == .ready || cameraState == .paused) {
            startCameraSession(true)
        }
    }
    
    private func isPreviewVisible() -> Bool {
        // Check if preview container is in window hierarchy and not hidden
        return previewContainer?.window != nil && !(previewContainer?.isHidden ?? true)
    }
    
    // MARK: - Cooldown Management
    
    /// Start the cooldown timer to prevent multiple scans of the same code
    private func startCooldownTimer() {
        // Cancel any existing timer
        cooldownTimer?.invalidate()
        
        // Create a new timer
        cooldownTimer = Timer.scheduledTimer(withTimeInterval: cooldownDuration, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            
            // Reset the last scanned value
            self.lastScannedValue = nil
            
            // Return to running state if we were in cooldown
            if self.cameraState == .cooldown {
                self.cameraState = .running
            }
        }
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension CodeScannerManager: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Skip processing if we're in cooldown state
        if cameraState == .cooldown {
            return
        }
        
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let barcodeValue = object.stringValue else { return }
        
        // Check if this is the same code we just scanned
        if barcodeValue == lastScannedValue {
            return
        }
        
        // Store the new scanned value
        lastScannedValue = barcodeValue
        
        // Get barcode type and title
        let (title, _) = getBarcodeTypeInfo(from: object.type)
        
        // Provide feedback (sound and/or haptic) if enabled
        FeedbackManager.shared.provideScanFeedback()
        
        // Enter cooldown state
        cameraState = .cooldown
        
        // Start cooldown timer
        startCooldownTimer()
        
        // Notify delegate
        delegate?.scannerDidDetectBarcode(value: barcodeValue, type: object.type, title: title)
    }
    
    // MARK: - Barcode Type Mapping
    
    /// Maps AVMetadataObject.ObjectType to appropriate title
    func getBarcodeTypeInfo(from objectType: AVMetadataObject.ObjectType) -> (title: String, type: Any?) {
        switch objectType {
        case .qr:
            return ("QR Code", nil) // QR codes are handled separately with detectQRCodeType
        case .ean8:
            return ("EAN 8", BarCodeType.ean8)
        case .ean13:
            return ("EAN 13", BarCodeType.ean13)
        case .pdf417:
            return ("PDF 417", BarCodeType.pdf417)
        case .code39:
            return ("Code 39", BarCodeType.code39)
        case .code93:
            return ("Code 93", BarCodeType.code93)
        case .code128:
            return ("Code 128", BarCodeType.code128)
        case .interleaved2of5:
            return ("ITF", BarCodeType.itf)
        case .upce:
            return ("UPC E", BarCodeType.upce)
        case .itf14:
            return ("UPC A", BarCodeType.upca) // Using UPC-A for ITF14
        default:
            return ("Barcode", nil)
        }
    }
}
