//
//  ScanResultViewController.swift
//  Quick QR
//
//  Created by Haider Rathore on 02/09/2025.
//

import UIKit
import AVFoundation

final class ScanResultViewController: UIViewController {
    // MARK: - Properties
    private var scanResult: ScanDataParser.ScanResult?
    private var scannedData: String = ""
    private var metadataObjectType: AVMetadataObject.ObjectType?
    
    /// Closure to be called when the view controller is dismissed
    var dismissHandler: (() -> Void)?
    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
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
        let iv = UIImageView(image: UIImage(named: "wifi-icon")?.withRenderingMode(.alwaysTemplate).withTintColor(.white))
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
        setupLayout()
        setupTopCard()
        setupInfoCard()
        setupActions()
        updateUIForScanResult()
    }
    
    // MARK: - Actions
    
    @objc private func closeButtonTapped() {
        // Call the dismissHandler before dismissing
        dismissHandler?()
        dismiss(animated: true)
    }
    
    @objc private func actionButtonTapped(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view, let actionType = view.accessibilityLabel else { return }
        
        switch actionType {
        case "Call":
            if case .qrCode(_, let data) = scanResult {
                let phoneNumber = data.replacingOccurrences(of: "tel:", with: "")
                    .replacingOccurrences(of: "telprompt:", with: "")
                if let url = URL(string: "tel://\(phoneNumber)") {
                    UIApplication.shared.open(url)
                }
            }
            
        case "Email":
            if case .qrCode(_, let data) = scanResult {
                var email = data
                if data.hasPrefix("mailto:") {
                    email = data
                } else {
                    email = "mailto:\(data)"
                }
                if let url = URL(string: email) {
                    UIApplication.shared.open(url)
                }
            }
            
        case "Open", "Open Map":
            if case .qrCode(_, let data) = scanResult, let url = URL(string: data) {
                UIApplication.shared.open(url)
            } else if case .socialQR(_, let data) = scanResult, let url = URL(string: data) {
                UIApplication.shared.open(url)
            }
            
        case "Save Contact":
            if case .qrCode(.contact, let data) = scanResult {
                // Create and save contact
                saveContact(from: data)
            }
            
        case "Connect":
            if case .qrCode(.wifi, let data) = scanResult {
                // Extract SSID and password
                connectToWifi(from: data)
            }
            
        case "Copy":
            if let data = getRawData() {
                UIPasteboard.general.string = data
                showToast(message: "Copied to clipboard")
            }
            
        case "Search Product":
            if case .barcode(_, let data, _) = scanResult, let url = URL(string: "https://www.google.com/search?q=\(data)") {
                UIApplication.shared.open(url)
            }
            
        case "Download":
            saveQRCodeImage()
            
        case "Share":
            shareQRCode()
            
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
        
        // Add close button
        view.addSubview(closeButton)
        
        // Add Ad container outside the scroll view
        adContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(adContainer)
        
        NSLayoutConstraint.activate([
            // Close button constraints
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
        rowsStack.spacing = 12
        rowsStack.disableIntrinsicContentSizeScrolling = true
        rowsStack.translatesAutoresizingMaskIntoConstraints = false
        infoCardView.addSubview(rowsStack)
        NSLayoutConstraint.activate([
            rowsStack.leadingAnchor.constraint(equalTo: infoCardView.leadingAnchor, constant: 16),
            rowsStack.trailingAnchor.constraint(equalTo: infoCardView.trailingAnchor, constant: -16),
            rowsStack.topAnchor.constraint(equalTo: infoCardView.topAnchor, constant: 16),
            rowsStack.bottomAnchor.constraint(equalTo: infoCardView.bottomAnchor, constant: -16),
            rowsStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
        
        // AD badge inside adContainer
        adLabel.translatesAutoresizingMaskIntoConstraints = false
        adContainer.addSubview(adLabel)
        NSLayoutConstraint.activate([
            adLabel.leadingAnchor.constraint(equalTo: adContainer.leadingAnchor, constant: 8),
            adLabel.topAnchor.constraint(equalTo: adContainer.topAnchor, constant: 8)
        ])
    }
    
    // MARK: - Builders
    private func makeAction(icon: UIImage?, title: String) -> UIView {
        // Create a container view that will be tappable
        let container = UIView()
        container.backgroundColor = .clear
        container.isUserInteractionEnabled = true
        
        // Create the stack view for content
        let v = UIStackView()
        v.axis = .vertical
        v.backgroundColor = .clear
        v.alignment = .center
        v.spacing = 6
        v.translatesAutoresizingMaskIntoConstraints = false
        
        let iv = UIImageView(image: icon)
        iv.tintColor = .appPrimary
        iv.contentMode = .scaleAspectFit
        iv.setContentHuggingPriority(.required, for: .vertical)
        iv.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iv.widthAnchor.constraint(equalToConstant: 32),
            iv.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        let lb = UILabel()
        lb.text = title
        lb.font = .systemFont(ofSize: 16, weight: .semibold)
        lb.textColor = .textPrimary
        
        v.addArrangedSubview(iv)
        v.addArrangedSubview(lb)
        
        // Add the stack view to the container
        container.addSubview(v)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            v.topAnchor.constraint(equalTo: container.topAnchor),
            v.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            v.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            v.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        // Store the title in the accessibilityLabel for action handling
        container.accessibilityLabel = title
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionButtonTapped(_:)))
        container.addGestureRecognizer(tapGesture)
        
        return container
    }
    
    /// Builds one info row view and returns it. Use to repeat rows.
    /// - Parameters:
    ///   - title: Left label text
    ///   - value: Right label text
    ///   - showsButton: Optional trailing button (e.g., copy)
    private func makeInfoRow(title: String,
                             value: String,
                             showsButton: Bool = false,
                             buttonImage: UIImage? = UIImage(systemName: "doc.on.doc")) -> UIView {
        let container = UIView()
        container.layer.cornerRadius = 12
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.alignment = .center
        rowStack.distribution = .fill
        rowStack.spacing = 8
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        titleLabel.textColor = .textSecondary
        titleLabel.widthAnchor.constraint(equalToConstant: 130).isActive = true
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        valueLabel.textColor = .textPrimary
        valueLabel.textAlignment = .left
        
        rowStack.addArrangedSubview(titleLabel)
        rowStack.addArrangedSubview(valueLabel)
        
        if showsButton {
            let btn = UIButton(type: .system)
            btn.setImage(buttonImage, for: .normal)
            btn.tintColor = .appPrimary
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.widthAnchor.constraint(equalToConstant: 40).isActive = true
            rowStack.addArrangedSubview(btn)
        }
        
        container.addSubview(rowStack)
        NSLayoutConstraint.activate([
            rowStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            rowStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            rowStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            rowStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
        
        return container
    }
    
    // MARK: - Update UI
    private func updateUIForScanResult() {
        guard let scanResult = scanResult else { return }
        
        // Update type icon and title
        typeIconView.image = scanResult.icon?.withRenderingMode(.alwaysTemplate)
        typeTitleLabel.text = scanResult.title
        
        // Generate QR code image for the scanned data
        if let qrImage = generateQRCode(from: scannedData) {
            qrImageView.image = qrImage
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
            rowsStack.addArrangedSubview(makeInfoRow(title: "Text:", value: data, showsButton: true))
            
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
            var email = data
            if data.hasPrefix("mailto:") {
                email = data.replacingOccurrences(of: "mailto:", with: "")
                rowsStack.addArrangedSubview(makeInfoRow(title: "Email:", value: email, showsButton: true))
            } else if data.hasPrefix("MATMSG:") {
                let to = extractValue(from: data, key: "TO:")
                let subject = extractValue(from: data, key: "SUB:")
                let body = extractValue(from: data, key: "BODY:")
                
                if let to = to {
                    rowsStack.addArrangedSubview(makeInfoRow(title: "To:", value: to, showsButton: true))
                }
                if let subject = subject {
                    rowsStack.addArrangedSubview(makeInfoRow(title: "Subject:", value: subject, showsButton: true))
                }
                if let body = body {
                    rowsStack.addArrangedSubview(makeInfoRow(title: "Body:", value: body, showsButton: true))
                }
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
            // Basic event info
            rowsStack.addArrangedSubview(makeInfoRow(title: "Event data:", value: data, showsButton: true))
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
                actionsStack.addArrangedSubview(makeAction(icon: UIImage(named: "copy-icon")?.withRenderingMode(.alwaysTemplate) ?? UIImage(systemName: "doc.on.doc"), title: "Copy"))
            }
            
        case .socialQR(let type, _):
            actionsStack.addArrangedSubview(makeAction(icon: type.icon?.withRenderingMode(.alwaysTemplate), title: "Open"))
            
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
        return ScanResultManager.shared.generateQRCode(from: string, size: size)
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
        ScanResultManager.shared.saveContact(from: vCardData) { [weak self] success, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if success {
                    self.showToast(message: "Contact saved successfully")
                } else if let error = error {
                    self.showToast(message: "Error saving contact: \(error.localizedDescription)")
                } else {
                    self.showToast(message: "Could not save contact")
                }
            }
        }
    }
    
    /// Connect to WiFi network
    private func connectToWifi(from wifiData: String) {
        let wifiInfo = ScanResultManager.shared.connectToWifi(from: wifiData)
        
        if let ssid = wifiInfo.ssid, let password = wifiInfo.password {
            // On iOS, we can't programmatically connect to WiFi networks
            // Show the information to the user instead
            let message = "Network: \(ssid)\nPassword copied to clipboard"
            UIPasteboard.general.string = password
            showToast(message: message)
        } else {
            showToast(message: "Invalid WiFi QR code format")
        }
    }
    
    /// Show toast message
    private func showToast(message: String) {
        ScanResultManager.shared.showToast(message: message, on: view)
    }
}
