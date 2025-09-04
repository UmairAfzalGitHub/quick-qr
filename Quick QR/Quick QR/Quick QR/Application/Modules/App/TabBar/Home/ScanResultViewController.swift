//
//  ScanResultViewController.swift
//  Quick QR
//
//  Created by Haider Rathore on 02/09/2025.
//

import UIKit
import AVFoundation
import EventKit
import Foundation
import GoogleMobileAds

final class ScanResultViewController: UIViewController {
    // MARK: - Properties
    private var scanResult: ScanDataParser.ScanResult?
    private var scannedData: String = ""
    private var metadataObjectType: AVMetadataObject.ObjectType?
    
    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let topCardView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 12
        v.layer.masksToBounds = true
        return v
    }()
    
    private let titleStack = UIStackView()
    private let iconContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.appPrimary
        v.layer.cornerRadius = 18
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private let typeIconView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "wifi-icon")?.withRenderingMode(.alwaysOriginal))
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    private let typeTitleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Wi‑Fi"
        lb.font = .systemFont(ofSize: 16, weight: .semibold)
        lb.textColor = .textPrimary
        return lb
    }()
    
    private let qrImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "qr-temp-icon"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let actionsStack = UIStackView()
    
    // Bottom information card
    private let infoCardView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 12
        v.layer.masksToBounds = true
        return v
    }()
    private let rowsStack = ScrollableStackView()
    
    // Ad view placeholder
    private let adContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.4)
        v.layer.cornerRadius = 12
        v.layer.masksToBounds = true
        return v
    }()
    private let adLabel: UILabel = {
        let lb = UILabel()
        lb.text = "AD"
        lb.font = .systemFont(ofSize: 12, weight: .bold)
        lb.textColor = .secondaryLabel
        return lb
    }()
    
    private var nativeAdView: NativeAdView!
    var nativeAd: GoogleMobileAds.NativeAd?
    
    // MARK: - Initializers
    init(scannedData: String, metadataObjectType: AVMetadataObject.ObjectType? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.scannedData = scannedData
        self.metadataObjectType = metadataObjectType
        self.scanResult = ScanDataParser.parse(data: scannedData, symbology: metadataObjectType)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appSecondaryBackground
        
        // Configure navigation bar
        navigationController?.navigationBar.tintColor = .appPrimary
        
        // Save scan result to history
        saveScanResultToHistory()
        
        // Setup UI components
        setupLayout()
        setupTopCard()
        setupInfoCard()
        setupActions()
        updateUIForScanResult()
        
        AdManager.shared.loadNativeAd(adId: AdMobConfig.native, from: self) { ad in
            self.showGoogleNativeAd(nativeAd: ad)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // If we're navigating back, resume camera feed in the scanner
        if isMovingFromParent, let scannerVC = navigationController?.viewControllers.first as? ScannerViewController {
            scannerVC.scannerManager.resumeCameraFeed()
        }
    }
    
    // MARK: - Actions
    
    private func saveScanResultToHistory() {
        guard let scanResult = scanResult else { return }
        switch scanResult {
        case .qrCode(let type, let data):
            HistoryManager.shared.saveScannedQRCodeHistory(type: type, content: data)
        case .socialQR(let type, let data):
            HistoryManager.shared.saveScannedSocialQRCodeHistory(type: type, content: data)
        case .barcode(let type, let data, _):
            HistoryManager.shared.saveScannedBarCodeHistory(type: type, content: data)
        case .unknown:
            // Optionally handle unknown types
            break
        }
    }
    
    @objc private func actionButtonTapped(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view, let actionType = view.accessibilityLabel else { return }
        guard let scanResult = scanResult else { return }
        
        // Get raw data from scan result
        let data = ScanResultManager.shared.getRawData(from: scanResult) ?? ""
        
        switch actionType {
        case "Call":
            if case .qrCode(.phone, _) = scanResult {
                ScanResultManager.shared.openPhoneCall(from: data) { success, errorMessage in
                    if !success, let message = errorMessage {
                        self.showToast(message: message)
                    }
                }
            }
            
        case "Email":
            if case .qrCode(.email, _) = scanResult {
                ScanResultManager.shared.openEmail(from: data) { success, errorMessage in
                    if !success, let message = errorMessage {
                        self.showToast(message: message)
                    }
                }
            }
            
        case "Open":
            if case .qrCode(.website, _) = scanResult {
                ScanResultManager.shared.openURL(data) { success, errorMessage in
                    if !success, let message = errorMessage {
                        self.showToast(message: message)
                    }
                }
            } else if case .socialQR(_, _) = scanResult {
                ScanResultManager.shared.openURL(data) { success, errorMessage in
                    if !success, let message = errorMessage {
                        self.showToast(message: message)
                    }
                }
            }
            
        case "Open Map":
            if case .qrCode(.location, _) = scanResult {
                ScanResultManager.shared.openLocation(from: data) { success, errorMessage in
                    if !success, let message = errorMessage {
                        self.showToast(message: message)
                    }
                }
            }
            
        case "Save Contact":
            if case .qrCode(.contact, _) = scanResult {
                ScanResultManager.shared.saveContact(from: data) { success, error in
                    if success {
                        self.showToast(message: "Contact saved successfully")
                    } else {
                        self.showToast(message: error?.localizedDescription ?? "Could not save contact")
                    }
                }
            }
            
        case "Connect":
            if case .qrCode(.wifi, _) = scanResult {
                let wifiInfo = ScanResultManager.shared.connectToWifi(from: data)
                if let ssid = wifiInfo.ssid, !ssid.isEmpty {
                    self.showToast(message: "Network information copied: \(ssid)")
                } else {
                    self.showToast(message: "Could not parse WiFi information")
                }
            }
            
        case "Send SMS":
            if case .qrCode(.text, _) = scanResult {
                ScanResultManager.shared.openSMS(from: data) { success, errorMessage in
                    if !success, let message = errorMessage {
                        self.showToast(message: message)
                    }
                }
            }
            
        case "Copy":
            UIPasteboard.general.string = data
            showToast(message: "Copied to clipboard")
            
        case "Search Product":
            if case .barcode(_, _, _) = scanResult {
                ScanResultManager.shared.searchProduct(barcode: data) { success, errorMessage in
                    if !success, let message = errorMessage {
                        self.showToast(message: message)
                    }
                }
            }
            
        case "Download":
            saveQRCodeImage()
            
        case "Share":
            shareQRCode()
            
        case "Add to Calendar":
            if case .qrCode(.events, _) = scanResult {
                // Add event to calendar
                addEventToCalendar(from: data)
            }
            
        default:
            break
        }
    }
    
    // MARK: - Layout
    private func setupLayout() {
        // Scroll container
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill
        contentStack.distribution = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        // Add Ad container outside the scroll view
        adContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(adContainer)
        
        NSLayoutConstraint.activate([
            
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            // Place scrollView above the adContainer
            scrollView.bottomAnchor.constraint(equalTo: adContainer.topAnchor),
            
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
        
        // Add arranged sections (adContainer removed from stack)
        contentStack.addArrangedSubview(topCardView)
        contentStack.addArrangedSubview(infoCardView)
        contentStack.setCustomSpacing(12, after: infoCardView)
        
        // Constrain adContainer to safe area at the bottom
        NSLayoutConstraint.activate([
            adContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            adContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            adContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            adContainer.heightAnchor.constraint(equalToConstant: 240)
        ])
    }
    
    private func setupTopCard() {
        // Title row
        titleStack.axis = .horizontal
        titleStack.alignment = .center
        titleStack.spacing = 10
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        
        iconContainer.addSubview(typeIconView)
        NSLayoutConstraint.activate([
            iconContainer.widthAnchor.constraint(equalToConstant: 36),
            iconContainer.heightAnchor.constraint(equalToConstant: 36),
            typeIconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            typeIconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            typeIconView.widthAnchor.constraint(equalToConstant: 22),
            typeIconView.heightAnchor.constraint(equalToConstant: 22)
        ])
        titleStack.addArrangedSubview(iconContainer)
        titleStack.addArrangedSubview(typeTitleLabel)
        
        // Actions stack
        actionsStack.axis = .horizontal
        actionsStack.alignment = .fill
        actionsStack.distribution = .fillEqually
        actionsStack.spacing = 46
        actionsStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout inside top card
        let inner = UIStackView(arrangedSubviews: [titleStack, qrImageView, actionsStack])
        inner.axis = .vertical
        inner.alignment = .center
        inner.spacing = 8
        inner.translatesAutoresizingMaskIntoConstraints = false
        
        topCardView.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.leadingAnchor.constraint(equalTo: topCardView.leadingAnchor, constant: 8),
            inner.trailingAnchor.constraint(equalTo: topCardView.trailingAnchor, constant: -8),
            inner.topAnchor.constraint(equalTo: topCardView.topAnchor, constant: 22),
            inner.bottomAnchor.constraint(equalTo: topCardView.bottomAnchor, constant: -16),
            qrImageView.widthAnchor.constraint(equalTo: inner.widthAnchor, multiplier: 0.4),
            qrImageView.heightAnchor.constraint(equalTo: qrImageView.widthAnchor)
        ])
    }
    
    private func setupActions() {
        // Create 3 action items (Connect, Download, Share)
        let connect = makeAction(icon: UIImage(named: "wifi-icon")?.withRenderingMode(.alwaysTemplate), title: "Connect")
        let download = makeAction(icon: UIImage(named: "download-result-icon"), title: "Download")
        let share = makeAction(icon: UIImage(named: "share-result-icon"), title: "Share")
        
        actionsStack.addArrangedSubview(connect)
        actionsStack.addArrangedSubview(download)
        actionsStack.addArrangedSubview(share)
    }
    
    private func setupInfoCard() {
        rowsStack.axis = .vertical
        rowsStack.spacing = 6  // Reduced from 12 to 6
        rowsStack.disableIntrinsicContentSizeScrolling = true
        rowsStack.translatesAutoresizingMaskIntoConstraints = false
        infoCardView.addSubview(rowsStack)
        NSLayoutConstraint.activate([
            rowsStack.leadingAnchor.constraint(equalTo: infoCardView.leadingAnchor, constant: 12), // Reduced from 16 to 12
            rowsStack.trailingAnchor.constraint(equalTo: infoCardView.trailingAnchor, constant: -12), // Reduced from -16 to -12
            rowsStack.topAnchor.constraint(equalTo: infoCardView.topAnchor, constant: 12), // Reduced from 16 to 12
            rowsStack.bottomAnchor.constraint(equalTo: infoCardView.bottomAnchor, constant: -12), // Reduced from -16 to -12
            rowsStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 80) // Reduced from 100 to 80
        ])
        
        // AD badge inside adContainer
        adLabel.translatesAutoresizingMaskIntoConstraints = false
        adContainer.addSubview(adLabel)
        NSLayoutConstraint.activate([
            adLabel.leadingAnchor.constraint(equalTo: adContainer.leadingAnchor, constant: 8),
            adLabel.topAnchor.constraint(equalTo: adContainer.topAnchor, constant: 8)
        ])
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
        nativeAdView.iconView?.isHidden = nativeAd.icon == nil
        
        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil
        
        // Disable user interaction on call-to-action view for SDK to handle touches
        nativeAdView.callToActionView?.isUserInteractionEnabled = false
        
        nativeAdView.nativeAd = nativeAd
    }
    
    private func setAdView(_ view: NativeAdView) {
        // Remove the previous ad view
        nativeAdView = view
        adContainer.addSubview(nativeAdView)
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout constraints for positioning the native ad view
        let viewDictionary = ["_nativeAdView": nativeAdView!]
        adContainer.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[_nativeAdView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
        )
        adContainer.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[_nativeAdView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
        )
    }
    
    // MARK: - Builders
    private func makeAction(icon: UIImage?, title: String) -> UIView {
        // Use ScanResultManager to create action button
        let container = ScanResultManager.shared.makeActionButton(icon: icon, title: title)
        
        // Set accessibility label for the container (used for tap handling)
        container.accessibilityLabel = title
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionButtonTapped(_:)))
        container.isUserInteractionEnabled = true
        container.addGestureRecognizer(tapGesture)
        
        return container
    }
    
    /// Builds one info row view and returns it. Use to repeat rows.
    /// - Parameters:
    ///   - title: Left label text
    ///   - value: Right label text
    ///   - showsButton: Optional trailing button (e.g., copy)
    ///   - buttonImage: Image for the button
    ///   - buttonAction: Optional selector for button action
    ///   - target: Optional target for button action
    private func makeInfoRow(title: String,
                             value: String,
                             showsButton: Bool = false,
                             buttonImage: UIImage? = UIImage(systemName: "doc.on.doc"),
                             buttonAction: Selector? = nil,
                             target: Any? = nil) -> UIView {
        // Use ScanResultManager to create info row
        return ScanResultManager.shared.makeInfoRow(title: title, 
                                                   value: value, 
                                                   showsButton: showsButton, 
                                                   buttonImage: buttonImage,
                                                   buttonAction: buttonAction,
                                                   target: target)
    }
    
    // MARK: - Update UI
    private func updateUIForScanResult() {
        guard let scanResult = scanResult else { return }
        
        // Update top title label with code type
        
        // Update type icon and title in the card
        typeIconView.image = scanResult.icon?.withRenderingMode(.alwaysOriginal)
        typeTitleLabel.text = scanResult.title
        
        // Set background color based on scan result type
        if case .socialQR = scanResult {
            // Remove background color for social icons
            iconContainer.backgroundColor = .clear
        } else {
            // Use app primary color for other icons
            iconContainer.backgroundColor = UIColor.appPrimary
        }
        
        // Generate appropriate image based on scan result type
        switch scanResult {
        case .barcode(let barCodeType, let data, _):
            // For barcodes, generate a barcode image using CodeGeneratorManager
            if let barcodeImage = CodeGeneratorManager.shared.generateBarcode(content: data, type: barCodeType) {
                qrImageView.image = barcodeImage
            } else {
                // Fallback to text representation for unsupported barcode types
                qrImageView.image = generateTextImage(text: data, barcodeType: barCodeType.title)
            }
            
        default:
            // For QR codes and other types, generate a QR code image
            if let qrImage = generateQRCode(from: scannedData) {
                qrImageView.image = qrImage
            }
        }
        
        // Update info rows based on scan result type
        updateInfoRows(for: scanResult)
        
        // Update action buttons based on scan result type
        updateActionButtons(for: scanResult)
    }
    
    private func updateInfoRows(for scanResult: ScanDataParser.ScanResult) {
        // Clear any existing rows
        rowsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add appropriate rows based on the scan result type
        switch scanResult {
        case .qrCode(let type, let data):
            addInfoRowsForQRCode(type: type, data: data)
            
        case .socialQR(let type, let data):
            addInfoRowsForSocialQR(type: type, data: data)
            
        case .barcode(let type, let data, _):
            addInfoRowsForBarcode(type: type, data: data)
            
        case .unknown(let data):
            // For unknown types, just show the raw data
            rowsStack.addArrangedSubview(makeInfoRow(title: "Raw data:", value: data, showsButton: true))
        }
    }
    
    private func addInfoRowsForQRCode(type: QRCodeType, data: String) {
        switch type {
        case .wifi:
            // Parse WiFi QR code (format: WIFI:S:<SSID>;T:<TYPE>;P:<PASSWORD>;H:<HIDDEN>;)
            let networkName = extractValue(from: data, key: "S:")
            let securityType = extractValue(from: data, key: "T:")
            let password = extractValue(from: data, key: "P:")
            
            rowsStack.addArrangedSubview(makeInfoRow(title: "Network name:", value: networkName ?? "Unknown", showsButton: true))
            if let securityType = securityType {
                rowsStack.addArrangedSubview(makeInfoRow(title: "Security type:", value: securityType, showsButton: false))
            }
            if let password = password {
                rowsStack.addArrangedSubview(makeInfoRow(title: "Password:", value: password, showsButton: true))
            }
            
        case .phone:
            // Format: tel:+1234567890 or telprompt:+1234567890
            let phoneNumber = data.replacingOccurrences(of: "tel:", with: "")
                .replacingOccurrences(of: "telprompt:", with: "")
            rowsStack.addArrangedSubview(makeInfoRow(title: "Phone number:", value: phoneNumber, showsButton: false))
            
        case .text:
            // Check if this is an SMS QR code (format: SMSTO:number:message or sms:number:message)
            if data.hasPrefix("SMSTO:") || data.hasPrefix("smsto:") || data.hasPrefix("SMS:") || data.hasPrefix("sms:") {
                // Parse SMS data
                let prefix = data.hasPrefix("SMSTO:") || data.hasPrefix("smsto:") ? "SMSTO:" : "sms:"
                let smsComponents = data.replacingOccurrences(of: prefix, with: "", options: .caseInsensitive).components(separatedBy: ":")
                
                if smsComponents.count >= 1 {
                    let phoneNumber = smsComponents[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    rowsStack.addArrangedSubview(makeInfoRow(title: "Phone number:", value: phoneNumber, showsButton: true))
                    
                    if smsComponents.count >= 2 {
                        let message = smsComponents[1].trimmingCharacters(in: .whitespacesAndNewlines)
                        rowsStack.addArrangedSubview(makeInfoRow(title: "Message:", value: message, showsButton: true))
                    }
                }
            } else {
                // Regular text QR code
                rowsStack.addArrangedSubview(makeInfoRow(title: "Text:", value: data, showsButton: true))
            }
            
        case .contact:
            // Basic parsing for vCard or MeCard format
            if data.contains("BEGIN:VCARD") {
                // Try FN field first, then N field for name
                var nameValue: String? = extractVCardValue(from: data, key: "FN:")
                if nameValue == nil || nameValue?.isEmpty == true {
                    nameValue = extractVCardValue(from: data, key: "N:")
                }
                
                let phone = extractVCardValue(from: data, key: "TEL:")
                let email = extractVCardValue(from: data, key: "EMAIL:")
                
                // Always show a name row
                if let name = nameValue, !name.isEmpty {
                    rowsStack.addArrangedSubview(makeInfoRow(title: "Name:", value: name, showsButton: false))
                } else {
                    rowsStack.addArrangedSubview(makeInfoRow(title: "Name:", value: "Contact", showsButton: false))
                }
                
                if let phone = phone {
                    rowsStack.addArrangedSubview(makeInfoRow(title: "Phone:", value: phone, showsButton: true))
                }
                if let email = email {
                    rowsStack.addArrangedSubview(makeInfoRow(title: "Email:", value: email, showsButton: true))
                }
            } else if data.contains("MECARD:") {
                // MeCard format
                let name = extractValue(from: data, key: "N:")
                let phone = extractValue(from: data, key: "TEL:")
                let email = extractValue(from: data, key: "EMAIL:")
                
                if let name = name {
                    rowsStack.addArrangedSubview(makeInfoRow(title: "Name:", value: name, showsButton: false))
                } else {
                    // Always include a name row even if we don't have a specific name
                    rowsStack.addArrangedSubview(makeInfoRow(title: "Name:", value: "Contact", showsButton: false))
                }
                if let phone = phone {
                    rowsStack.addArrangedSubview(makeInfoRow(title: "Phone:", value: phone, showsButton: true))
                }
                if let email = email {
                    rowsStack.addArrangedSubview(makeInfoRow(title: "Email:", value: email, showsButton: true))
                }
            } else {
                // Other contact format
                // Always include a name row
                rowsStack.addArrangedSubview(makeInfoRow(title: "Name:", value: "Contact", showsButton: false))
                rowsStack.addArrangedSubview(makeInfoRow(title: "Contact data:", value: data, showsButton: true))
            }
            
        case .email:
            // Format: mailto:email@example.com or MATMSG:TO:email@example.com;SUB:subject;BODY:body;;
            if data.hasPrefix("mailto:") {
                // Parse mailto: format which can include subject and body as query parameters
                // Example: mailto:someone@example.com?subject=Hello&body=Message
                let mailtoComponents = data.components(separatedBy: "?")
                let emailAddress = mailtoComponents[0].replacingOccurrences(of: "mailto:", with: "")
                
                // Add email row
                rowsStack.addArrangedSubview(makeInfoRow(title: "Email:", value: emailAddress, showsButton: true))
                
                // Parse query parameters if they exist
                if mailtoComponents.count > 1, let queryItems = mailtoComponents[1].components(separatedBy: "&").map({ $0.components(separatedBy: "=") }) as? [[String]] {
                    for item in queryItems {
                        if item.count == 2 {
                            let key = item[0].lowercased()
                            let value = item[1].replacingOccurrences(of: "+", with: " ")
                                .removingPercentEncoding ?? item[1]
                            
                            if key == "subject" {
                                rowsStack.addArrangedSubview(makeInfoRow(title: "Subject:", value: value, showsButton: true))
                            } else if key == "body" {
                                rowsStack.addArrangedSubview(makeInfoRow(title: "Content:", value: value, showsButton: true))
                            }
                        }
                    }
                }
            } else if data.hasPrefix("MATMSG:") {
                let to = extractValue(from: data, key: "TO:")
                let subject = extractValue(from: data, key: "SUB:")
                let body = extractValue(from: data, key: "BODY:")
                
                if let to = to {
                    rowsStack.addArrangedSubview(makeInfoRow(title: "Email:", value: to, showsButton: true))
                }
                if let subject = subject {
                    rowsStack.addArrangedSubview(makeInfoRow(title: "Subject:", value: subject, showsButton: true))
                }
                if let body = body {
                    rowsStack.addArrangedSubview(makeInfoRow(title: "Content:", value: body, showsButton: true))
                }
            } else {
                // Plain email address
                rowsStack.addArrangedSubview(makeInfoRow(title: "Email:", value: data, showsButton: true))
            }
            
        case .website:
            rowsStack.addArrangedSubview(makeInfoRow(title: "URL:", value: data, showsButton: true))
            
        case .location:
            // Format: geo:latitude,longitude or maps URL
            if data.hasPrefix("geo:") {
                let coordinates = data.replacingOccurrences(of: "geo:", with: "")
                rowsStack.addArrangedSubview(makeInfoRow(title: "Coordinates:", value: coordinates, showsButton: true))
            } else {
                rowsStack.addArrangedSubview(makeInfoRow(title: "Location URL:", value: data, showsButton: true))
            }
            
        case .events:
            // Parse and display event data in multiple rows
            if data.hasPrefix("BEGIN:VEVENT") {
                // iCalendar format
                if let summary = extractEventValue(from: data, key: "SUMMARY:") {
                    rowsStack.addArrangedSubview(makeInfoRow(title: "Title:", value: summary, showsButton: true))
                }
                if let location = extractEventValue(from: data, key: "LOCATION:") {
                    rowsStack.addArrangedSubview(makeInfoRow(title: "Location:", value: location, showsButton: true))
                }
                if let description = extractEventValue(from: data, key: "DESCRIPTION:") {
                    rowsStack.addArrangedSubview(makeInfoRow(title: "Description:", value: description, showsButton: true))
                }
                if let startDate = extractEventValue(from: data, key: "DTSTART:") {
                    rowsStack.addArrangedSubview(makeInfoRow(title: "Start:", value: formatEventDate(startDate), showsButton: false))
                }
                if let endDate = extractEventValue(from: data, key: "DTEND:") {
                    rowsStack.addArrangedSubview(makeInfoRow(title: "End:", value: formatEventDate(endDate), showsButton: false))
                }
            } else {
                // Unknown format, show raw data
                rowsStack.addArrangedSubview(makeInfoRow(title: "Event data:", value: data, showsButton: true))
            }
        }
    }
    
    private func addInfoRowsForSocialQR(type: SocialQRCodeType, data: String) {
        // For social QR codes, show the platform and the URL/username
        rowsStack.addArrangedSubview(makeInfoRow(title: "Platform:", value: type.title, showsButton: false))
        rowsStack.addArrangedSubview(makeInfoRow(title: "URL:", value: data, showsButton: true))
        
        // Extract username if possible
        if let username = extractUsername(from: data, for: type) {
            rowsStack.addArrangedSubview(makeInfoRow(title: "Username:", value: username, showsButton: true))
        }
    }
    
    private func addInfoRowsForBarcode(type: BarCodeType, data: String) {
        // For barcodes, only show the value without the type label
        // This makes it look cleaner and more focused on the actual data
        rowsStack.addArrangedSubview(makeInfoRow(title: "Value:", value: data, showsButton: false))
        
        // For specific barcode types, add additional information
        switch type {
        case .isbn:
            // Could add book lookup functionality in the future
            break
            
        case .ean13, .ean8, .upca, .upce:
            // Could add product lookup functionality in the future
            break
            
        default:
            break
        }
    }
    
    private func updateActionButtons(for scanResult: ScanDataParser.ScanResult) {
        // Clear existing action buttons
        actionsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add appropriate action buttons based on the scan result type
        switch scanResult {
        case .qrCode(let type, let data):
            switch type {
            case .wifi:
                actionsStack.addArrangedSubview(makeAction(icon: UIImage(named: "wifi-icon")?.withRenderingMode(.alwaysTemplate), title: "Connect"))
            case .phone:
                let phoneNumber = data.replacingOccurrences(of: "tel:", with: "")
                    .replacingOccurrences(of: "telprompt:", with: "")
                let callAction = makeAction(icon: UIImage(named: "phone-icon")?.withRenderingMode(.alwaysTemplate), title: "Call")
                callAction.tag = 1001 // Tag for phone action
                actionsStack.addArrangedSubview(callAction)
            case .email:
                actionsStack.addArrangedSubview(makeAction(icon: UIImage(named: "email-icon")?.withRenderingMode(.alwaysTemplate), title: "Email"))
            case .website:
                actionsStack.addArrangedSubview(makeAction(icon: UIImage(named: "website-icon")?.withRenderingMode(.alwaysTemplate), title: "Open"))
            case .location:
                actionsStack.addArrangedSubview(makeAction(icon: UIImage(named: "location-icon")?.withRenderingMode(.alwaysTemplate), title: "Open Map"))
            case .contact:
                actionsStack.addArrangedSubview(makeAction(icon: UIImage(named: "contact-icon")?.withRenderingMode(.alwaysTemplate), title: "Save Contact"))
            case .events:
                actionsStack.addArrangedSubview(makeAction(icon: UIImage(named: "events-icon")?.withRenderingMode(.alwaysTemplate), title: "Add to Calendar"))
            case .text:
                // Check if this is an SMS QR code
                if data.hasPrefix("SMSTO:") || data.hasPrefix("smsto:") || data.hasPrefix("SMS:") || data.hasPrefix("sms:") {
                    actionsStack.addArrangedSubview(makeAction(icon: UIImage(named: "message-icon")?.withRenderingMode(.alwaysTemplate) ?? UIImage(systemName: "message.fill"), title: "Send SMS"))
                } else {
                    actionsStack.addArrangedSubview(makeAction(icon: UIImage(named: "copy-icon")?.withRenderingMode(.alwaysTemplate) ?? UIImage(systemName: "doc.on.doc"), title: "Copy"))
                }
            }
            
        case .socialQR(let type, _):
            // Use the social platform's icon for the action button
            let socialIcon = type.icon?.withRenderingMode(.alwaysOriginal)
            actionsStack.addArrangedSubview(makeAction(icon: socialIcon, title: "Open"))
            
        case .barcode(let type, let data, _):
            // For product barcodes, show "Search Product"
            if [.ean8, .ean13, .upca, .upce].contains(where: { $0 == type }) {
                actionsStack.addArrangedSubview(makeAction(icon: UIImage(named: "search-icon")?.withRenderingMode(.alwaysTemplate) ?? UIImage(systemName: "magnifyingglass"), title: "Search Product"))
            } else {
                actionsStack.addArrangedSubview(makeAction(icon: type.icon?.withRenderingMode(.alwaysTemplate), title: "Copy"))
            }
            
        case .unknown(_):
            actionsStack.addArrangedSubview(makeAction(icon: UIImage(named: "copy-icon")?.withRenderingMode(.alwaysTemplate) ?? UIImage(systemName: "doc.on.doc"), title: "Copy"))
        }
        
        // Always add download and share buttons
        actionsStack.addArrangedSubview(makeAction(icon: UIImage(named: "download-result-icon"), title: "Download"))
        actionsStack.addArrangedSubview(makeAction(icon: UIImage(named: "share-result-icon"), title: "Share"))
    }
    
    // MARK: - Helper Methods
    
    /// Generate a QR code image from a string
    private func generateQRCode(from string: String, size: CGFloat = 200) -> UIImage? {
        return CodeGeneratorManager.shared.generateQRCode(from: string, size: CGSize(width: size, height: size))
    }
    
    
    /// Generate a text image for barcode types that can't be visually represented
    private func generateTextImage(text: String, barcodeType: String, size: CGFloat = 200) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        
        let image = renderer.image { context in
            // Draw background
            UIColor.white.setFill()
            context.fill(CGRect(x: 0, y: 0, width: size, height: size))
            
            // Draw barcode type text
            let typeAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                .foregroundColor: UIColor.black
            ]
            
            let typeText = "\(barcodeType)"
            let typeSize = typeText.size(withAttributes: typeAttributes)
            let typeRect = CGRect(
                x: (size - typeSize.width) / 2,
                y: size / 3 - typeSize.height / 2,
                width: typeSize.width,
                height: typeSize.height
            )
            typeText.draw(in: typeRect, withAttributes: typeAttributes)
            
            // Draw barcode value text
            let valueAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.darkGray
            ]
            
            // Truncate text if too long
            let maxLength = 20
            let displayText = text.count > maxLength ? text.prefix(maxLength) + "..." : text
            let valueText = String(displayText)
            
            let valueSize = valueText.size(withAttributes: valueAttributes)
            let valueRect = CGRect(
                x: (size - valueSize.width) / 2,
                y: 2 * size / 3 - valueSize.height / 2,
                width: valueSize.width,
                height: valueSize.height
            )
            valueText.draw(in: valueRect, withAttributes: valueAttributes)
            
            // Draw barcode-like lines
            UIColor.black.setStroke()
            let lineY = size / 2
            let lineHeight = size / 10
            
            for i in 0..<10 {
                let lineWidth = CGFloat.random(in: 2...10)
                let lineX = CGFloat(i) * (size / 10) + CGFloat.random(in: 0...5)
                let linePath = UIBezierPath(rect: CGRect(x: lineX, y: lineY - lineHeight/2, width: lineWidth, height: lineHeight))
                linePath.stroke()
                linePath.fill()
            }
        }
        
        return image
    }
    
    /// Extract a value from a string using a key
    private func extractValue(from string: String, key: String) -> String? {
        return ScanResultManager.shared.extractValue(from: string, key: key)
    }
    
    /// Extract a value from a vCard string
    private func extractVCardValue(from string: String, key: String) -> String? {
        return ScanResultManager.shared.extractVCardValue(from: string, key: key)
    }
    
    /// Extract username from social media URL
    private func extractUsername(from url: String, for type: SocialQRCodeType) -> String? {
        return ScanResultManager.shared.extractUsername(from: url, for: type)
    }
    
    /// Get raw data from scan result
    private func getRawData() -> String? {
        return ScanResultManager.shared.getRawData(from: scanResult)
    }
    
    /// Save QR code image to photo library
    private func saveQRCodeImage() {
        guard let qrImage = qrImageView.image else {
            showToast(message: "Could not save QR code image")
            return
        }
        
        ScanResultManager.shared.saveQRCodeImage(qrImage) { success, error in
            if success {
                self.showToast(message: "Image saved to Photos")
            } else if let error = error {
                self.showToast(message: "Error saving image: \(error.localizedDescription)")
            } else {
                self.showToast(message: "Failed to save image")
            }
        }
    }
    
    /// Share QR code image
    private func shareQRCode() {
        guard let qrImage = qrImageView.image else { return }
        ScanResultManager.shared.shareQRCode(qrImage, from: self)
    }
    
    /// Save contact from vCard data
    private func saveContact(from vCardData: String) {
        ScanResultManager.shared.handleSaveContact(from: vCardData, on: self)
    }
    
    /// Connect to WiFi network
    private func connectToWifi(from wifiData: String) {
        ScanResultManager.shared.handleWifiConnection(from: wifiData) { success, message in
            self.showToast(message: message)
        }
    }
    
    /// Show toast message
    private func showToast(message: String) {
        ScanResultManager.shared.showToast(message: message, on: view)
    }
    
    // MARK: - Event Handling
    
    /// Extract a value from an iCalendar event string
    private func extractEventValue(from eventData: String, key: String) -> String? {
        let lines = eventData.components(separatedBy: .newlines)
        
        for line in lines {
            if line.hasPrefix(key) {
                return line.replacingOccurrences(of: key, with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        return nil
    }
    
    /// Format an iCalendar date string to a more readable format
    private func formatEventDate(_ dateString: String) -> String {
        // iCalendar format: YYYYMMDDTHHMMSSZ or YYYYMMDD
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MMM d, yyyy h:mm a"
            formatter.timeZone = TimeZone.current
            return formatter.string(from: date)
        } else {
            // Try without time component
            formatter.dateFormat = "yyyyMMdd"
            if let date = formatter.date(from: dateString) {
                formatter.dateFormat = "MMM d, yyyy"
                return formatter.string(from: date)
            }
        }
        
        return dateString // Return original if parsing fails
    }
    
    /// Add an event to the calendar from iCalendar data
    private func addEventToCalendar(from eventData: String) {
        // Parse event data
        let summary = extractEventValue(from: eventData, key: "SUMMARY:") ?? "New Event"
        let location = extractEventValue(from: eventData, key: "LOCATION:")
        let description = extractEventValue(from: eventData, key: "DESCRIPTION:")
        let startDateString = extractEventValue(from: eventData, key: "DTSTART:")
        let endDateString = extractEventValue(from: eventData, key: "DTEND:")
        
        // Create event
        let eventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event) { [weak self] granted, error in
            guard let self = self else { return }
            
            if !granted {
                DispatchQueue.main.async {
                    self.showToast(message: "Calendar access denied")
                }
                return
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.showToast(message: "Error: \(error.localizedDescription)")
                }
                return
            }
            
            let event = EKEvent(eventStore: eventStore)
            event.title = summary
            event.location = location
            event.notes = description
            
            // Set start and end dates if available
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            
            if let startDateString = startDateString, let startDate = formatter.date(from: startDateString) {
                event.startDate = startDate
                
                // If no end date, set it to 1 hour after start
                if let endDateString = endDateString, let endDate = formatter.date(from: endDateString) {
                    event.endDate = endDate
                } else {
                    event.endDate = startDate.addingTimeInterval(3600) // 1 hour
                }
            } else {
                // Try without time component
                formatter.dateFormat = "yyyyMMdd"
                
                if let startDateString = startDateString, let startDate = formatter.date(from: startDateString) {
                    event.startDate = startDate
                    
                    if let endDateString = endDateString, let endDate = formatter.date(from: endDateString) {
                        event.endDate = endDate
                    } else {
                        event.endDate = startDate.addingTimeInterval(86400) // 1 day
                    }
                } else {
                    // Use current date if parsing fails
                    let now = Date()
                    event.startDate = now
                    event.endDate = now.addingTimeInterval(3600) // 1 hour
                }
            }
            
            event.calendar = eventStore.defaultCalendarForNewEvents
            
            do {
                try eventStore.save(event, span: .thisEvent)
                DispatchQueue.main.async {
                    self.showToast(message: "Event added to calendar")
                }
            } catch {
                DispatchQueue.main.async {
                    self.showToast(message: "Could not save event: \(error.localizedDescription)")
                }
            }
        }
    }
}
