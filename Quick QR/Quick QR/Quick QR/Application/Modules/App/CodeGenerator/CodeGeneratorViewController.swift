//
//  CodeGeneratorViewController.swift
//  Quick QR
//
//  Created by Haider Rathore on 28/08/2025.
//

import UIKit
import IOS_Helpers
import Foundation

class CodeGeneratorViewController: UIViewController {
    
    // MARK: - Static Factory Method
    static func createFromHistoryItem(_ historyItem: HistoryItem) -> CodeGeneratorViewController? {
        let viewController = CodeGeneratorViewController()
        
        // Convert history item to appropriate code type
        switch historyItem.type {
        case .qrCode:
            if let qrType = QRCodeType.allCases.first(where: { $0.title.lowercased() == historyItem.subtype.lowercased() }) {
                viewController.currentCodeType = qrType
                viewController.prefilledContent = historyItem.content
            } else {
                return nil
            }
            
        case .socialQRCode:
            if let socialType = SocialQRCodeType.allCases.first(where: { $0.title.lowercased() == historyItem.subtype.lowercased() }) {
                viewController.currentCodeType = socialType
                viewController.prefilledContent = historyItem.content
            } else {
                return nil
            }
            
        case .barCode:
            if let barType = BarCodeType.allCases.first(where: { $0.title.lowercased() == historyItem.subtype.lowercased() }) {
                viewController.currentCodeType = barType
                viewController.prefilledContent = historyItem.content
            } else {
                return nil
            }
        }
        
        return viewController
    }
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let actionButton = AppButtonView()
    private let adContainerView = UIView()
    
    internal var wifiView: WifiView?
    internal var emailView: EmailView?
    internal var websiteView: WebsiteView?
    internal var phoneView: PhoneView?
    internal var textView: TextView?
    internal var contactsView: ContactsView?
    internal var locationView: LocationView?
    internal var tiktokView: TiktokView?
    internal var instagramView: InstagramView?
    internal var facebookView: FacebookView?
    internal var xView: XView?
    internal var spotifyView: SpotifyView?
    internal var youtubeView: YoutubeView?
    internal var whatsappView: WhatsappView?
    internal var viberView: ViberView?
    internal var barCodeView: BarCodeView?
    internal var calendarView: CalendarView?
    
    // MARK: - Content View (to be replaced)
    private let replaceableContentView = UIView()
    private var placeholderHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Code Type
    internal var currentCodeType: CodeTypeProtocol?
    internal var buttonAction: (() -> Void)?
    
    // MARK: - Prefilled Content
    internal var prefilledContent: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure(with: currentCodeType!)
        setupUI()
        setupConstraints()
        setupActions()
        
        // Apply prefilled content if available
        if let content = prefilledContent {
            applyPrefilledContent(content)
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Configure scroll view
        scrollView.backgroundColor = .clear
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        
        // Configure content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure replaceable content view
        replaceableContentView.translatesAutoresizingMaskIntoConstraints = false
        replaceableContentView.backgroundColor = .clear
        
        // Configure action button
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.configure(with: .primary(title: "Create", image: nil))
        
        // Configure ad container
        adContainerView.translatesAutoresizingMaskIntoConstraints = false
        adContainerView.backgroundColor = .systemGray6
        adContainerView.layer.cornerRadius = 8
        adContainerView.layer.borderWidth = 1
        adContainerView.layer.borderColor = UIColor.systemGray4.cgColor
        
        // Add subviews
        view.addSubview(scrollView)
        view.addSubview(actionButton)
        view.addSubview(adContainerView)
        
        scrollView.addSubview(contentView)
        contentView.addSubview(replaceableContentView)
    }
    
    private func setupConstraints() {
        // Store the placeholder height constraint so we can remove it later
        placeholderHeightConstraint = replaceableContentView.heightAnchor.constraint(equalToConstant: 200)
        placeholderHeightConstraint?.priority = UILayoutPriority(999)
        placeholderHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            // Ad Container - Fixed at bottom
            adContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 18),
            adContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -18),
            adContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18),
            adContainerView.heightAnchor.constraint(equalToConstant: 240),
            
            // Action Button - Above ad with 20pt padding
            actionButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 70),
            actionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -70),
            actionButton.bottomAnchor.constraint(equalTo: adContainerView.topAnchor, constant: -20),
            actionButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Scroll View - Above button with 18pt padding from top and sides
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 18),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -18),
            scrollView.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -18),
            
            // Content View - Inside scroll view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Replaceable Content View - Inside content view
            replaceableContentView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            replaceableContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            replaceableContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            replaceableContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
        actionButton.addGestureRecognizer(tapGesture)
    }
    
    @objc private func buttonTapped() {
        // Handle code generation based on current type
        guard let codeType = currentCodeType else {
            print("No Code type configured")
            return
        }
        
        // Call custom button action if provided, otherwise handle default generation
        if let customAction = buttonAction {
            customAction()
        } else {
            handleCodeGeneration(for: codeType)
        }
    }
    
    /// Default Code generation handler
    private func handleCodeGeneration(for codeType: CodeTypeProtocol) {
        print("Generating Code for: \(codeType.title)")
        
        var generatedImage: UIImage?
        var contentToSave: String = ""
        
        if let qrCodeType = codeType as? QRCodeType {
            generatedImage = generateQRCode(for: qrCodeType)
            // Save content based on QR code type
            contentToSave = getQRCodeContent(for: qrCodeType)
            if !contentToSave.isEmpty {
                HistoryManager.shared.saveQRCodeHistory(type: qrCodeType, content: contentToSave)
            }
        } else if let socialQRCodeType = codeType as? SocialQRCodeType {
            generatedImage = generateSocialQRCode(for: socialQRCodeType)
            // Save content based on social QR code type
            contentToSave = getSocialQRCodeContent(for: socialQRCodeType)
            if !contentToSave.isEmpty {
                HistoryManager.shared.saveSocialQRCodeHistory(type: socialQRCodeType, content: contentToSave)
            }
        } else if let barCodeType = codeType as? BarCodeType {
            generatedImage = generateBarCode(for: barCodeType)
            // Save barcode to history
            if let content = barCodeView?.getContent(), !content.isEmpty {
                HistoryManager.shared.saveBarCodeHistory(type: barCodeType, content: content)
            }
        }
        
        guard let generatedImage = generatedImage else {
            showAlert(title: "Error", message: "Failed to generate code. Please check your input and try again.")
            return
        }
        
        let resultVC = CodeGenerationResultViewController()
        configureResultVC(resultVC, with: generatedImage)
        navigationController?.pushViewController(resultVC, animated: true)
    }
    
    private func generateQRCode(for type: QRCodeType) -> UIImage? {
        switch type {
        case .wifi:
            guard let wifiView = wifiView,
                  let ssid = wifiView.getSSID(),
                  let password = wifiView.getPassword(),
                  !ssid.isEmpty else {
                return nil
            }
            return CodeGeneratorManager.shared.generateWifiQRCode(ssid: ssid, password: password, isWEP: wifiView.isWEP())
            
        case .phone:
            guard let phoneView = phoneView,
                  let phoneNumber = phoneView.getPhoneNumber(),
                  !phoneNumber.isEmpty else {
                return nil
            }
            return CodeGeneratorManager.shared.generateQRCode(from: "tel:\(phoneNumber)")
            
        case .text:
            guard let textView = textView,
                  let text = textView.getText(),
                  !text.isEmpty else {
                return nil
            }
            
            // Check if we have a phone number for SMS
            if let phoneNumber = textView.phoneNumberText, !phoneNumber.isEmpty {
                // Format as SMS with phone number and text
                return CodeGeneratorManager.shared.generateQRCode(from: "SMSTO:\(phoneNumber):\(text)")
            } else {
                // Regular text QR code
                return CodeGeneratorManager.shared.generateQRCode(from: text)
            }
            
        case .contact:
            guard let contactsView = contactsView,
                  let name = contactsView.getName(),
                  let phone = contactsView.getPhone(),
                  let email = contactsView.getEmail() else {
                return nil
            }
            return CodeGeneratorManager.shared.generateContactQRCode(name: name, phone: phone, email: email, address: "")
            
        case .email:
            guard let emailView = emailView,
                  let email = emailView.getEmail(),
                  let subject = emailView.getSubject(),
                  let body = emailView.getBody(),
                  !email.isEmpty else {
                return nil
            }
            return CodeGeneratorManager.shared.generateEmailQRCode(email: email, subject: subject, body: body)
            
        case .website:
            guard let websiteView = websiteView,
                  let url = websiteView.getURL(),
                  !url.isEmpty else {
                return nil
            }
            return CodeGeneratorManager.shared.generateQRCode(from: url)
            
        case .location:
            guard let locationView = locationView,
                  let latitudeStr = locationView.getLatitude(),
                  let longitudeStr = locationView.getLongitude(),
                  let latitude = Double(latitudeStr),
                  let longitude = Double(longitudeStr) else {
                return nil
            }
            return CodeGeneratorManager.shared.generateLocationQRCode(latitude: latitude, longitude: longitude)
            
        case .events:
            guard let calendarView = calendarView,
                  let title = calendarView.getTitle(),
                  let startDate = calendarView.getStartDate(),
                  let endDate = calendarView.getEndDate(),
                  let location = calendarView.getLocation() else {
                return nil
            }
            
            let description = calendarView.getDescription() ?? ""
            let isAllDay = calendarView.isAllDay()
            
            // For all-day events, adjust the dates to remove time component
            var adjustedStartDate = startDate
            var adjustedEndDate = endDate
            
            if isAllDay {
                // Set start date to beginning of day
                let calendar = Calendar.current
                adjustedStartDate = calendar.startOfDay(for: startDate)
                
                // For all-day events, the end date should be the next day's start
                // This is the standard for calendar events
                adjustedEndDate = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate)) ?? endDate
            }
            
            return CodeGeneratorManager.shared.generateCalendarEventQRCode(
                title: title,
                startDate: adjustedStartDate,
                endDate: adjustedEndDate,
                location: location,
                description: description
            )
        }
    }
    
    private func generateSocialQRCode(for type: SocialQRCodeType) -> UIImage? {
        var username = ""
        
        switch type {
        case .facebook:
            guard let facebookView = facebookView else {
                return nil
            }
            
            // Check if a custom URL is provided
            if let customUrl = facebookView.getUrl(), !customUrl.isEmpty {
                // Use the custom URL directly
                return CodeGeneratorManager.shared.generateQRCode(from: customUrl)
            }
            
            // Fall back to username-based URL if no custom URL is provided
            guard let user = facebookView.getUsername(), !user.isEmpty else {
                return nil
            }
            username = user
            
        case .instagram:
            guard let instagramView = instagramView else {
                return nil
            }
            
            // Check if a custom URL is provided
            if let customUrl = instagramView.getUrl(), !customUrl.isEmpty {
                // Use the custom URL directly
                return CodeGeneratorManager.shared.generateQRCode(from: customUrl)
            }
            
            // Fall back to username-based URL if no custom URL is provided
            guard let user = instagramView.getUsername(), !user.isEmpty else {
                return nil
            }
            username = user
            
        case .tiktok:
            guard let tiktokView = tiktokView,
                  let user = tiktokView.getUsername(),
                  !user.isEmpty else {
                return nil
            }
            username = user
            
        case .x:
            guard let xView = xView else {
                return nil
            }
            
            // Check if a custom URL is provided
            if let customUrl = xView.getUrl(), !customUrl.isEmpty {
                // Use the custom URL directly
                return CodeGeneratorManager.shared.generateQRCode(from: customUrl)
            }
            
            // Fall back to username-based URL if no custom URL is provided
            guard let user = xView.getUsername(), !user.isEmpty else {
                return nil
            }
            username = user
            
        case .whatsapp:
            guard let whatsappView = whatsappView,
                  let user = whatsappView.getPhoneNumber(),
                  !user.isEmpty else {
                return nil
            }
            username = user
            
        case .youtube:
            guard let youtubeView = youtubeView else {
                return nil
            }
            
            // Check if a custom URL is provided
            if let customUrl = youtubeView.getUrl(), !customUrl.isEmpty {
                // Use the custom URL directly
                return CodeGeneratorManager.shared.generateQRCode(from: customUrl)
            }
            
            // Fall back to username-based URL if no custom URL is provided
            guard let user = youtubeView.getUsername(), !user.isEmpty else {
                return nil
            }
            username = user
            
        case .spotify:
            guard let spotifyView = spotifyView else {
                return nil
            }
            
            // Check if a custom URL is provided
            if let customUrl = spotifyView.getUrl(), !customUrl.isEmpty {
                // Use the custom URL directly
                return CodeGeneratorManager.shared.generateQRCode(from: customUrl)
            }
            
            // Fall back to username-based URL if no custom URL is provided
            guard let user = spotifyView.getUsername(), !user.isEmpty else {
                return nil
            }
            username = user
            
        case .viber:
            guard let viberView = viberView,
                  let user = viberView.getPhoneNumber(),
                  !user.isEmpty else {
                return nil
            }
            username = user
        }
        
        // Generate the social QR code based on the type and username
        return CodeGeneratorManager.shared.generateSocialQRCode(type: type, username: username)
    }
    
    private func generateBarCode(for type: BarCodeType) -> UIImage? {
        print("[CodeGeneratorViewController] Attempting to generate barcode of type: \(type.title)")
        
        guard let barCodeView = barCodeView else {
            print("[CodeGeneratorViewController] ERROR: barCodeView is nil")
            return nil
        }
        
        guard let content = barCodeView.getContent() else {
            print("[CodeGeneratorViewController] ERROR: No content provided for barcode")
            return nil
        }
        
        if content.isEmpty {
            print("[CodeGeneratorViewController] ERROR: Empty content for barcode")
            return nil
        }
        
        print("[CodeGeneratorViewController] Generating barcode with content: '\(content)'")
        
        let image = CodeGeneratorManager.shared.generateBarcode(content: content, type: type)
        
        if image == nil {
            print("[CodeGeneratorViewController] ERROR: Failed to generate barcode image")
        } else {
            print("[CodeGeneratorViewController] Successfully generated barcode image")
        }
        
        return image
    }
    
    private func configureResultVC(_ resultVC: CodeGenerationResultViewController, with image: UIImage) {
        guard let codeType = currentCodeType else {
            print("[CodeGeneratorViewController] Error: No code type available")
            return
        }
        
        print("[CodeGeneratorViewController] Configuring result VC for code type: \(codeType)")
        
        // Set the generated image based on code type
        if codeType is BarCodeType {
            print("[CodeGeneratorViewController] Setting barcode image")
            resultVC.setBarCodeImage(image)
            if let barCodeType = codeType as? BarCodeType {
                resultVC.setBarCodeType(icon: barCodeType.icon, title: barCodeType.title)
            }
        } else {
            print("[CodeGeneratorViewController] Setting QR code image")
            resultVC.setQRCodeImage(image)
        }
        
        // Set title and description based on code type
        var title = ""
        var description = ""
        
        if let qrType = codeType as? QRCodeType {
            title = qrType.title
            switch qrType {
            case .wifi:
                if let wifiView = wifiView {
                    title = "Wi-Fi Name"
                    description = wifiView.getSSID() ?? ""
                }
            case .phone:
                if let phoneView = phoneView {
                    title = "Phone Number"
                    description = phoneView.getPhoneNumber() ?? ""
                }
            case .text:
                if let textView = textView {
                    if let phoneNumber = textView.phoneNumberText, !phoneNumber.isEmpty {
                        title = "SMS"
                        description = "To: \(phoneNumber)"
                    } else {
                        title = "Text"
                        description = String(textView.getText()?.prefix(20) ?? "") + (textView.getText()?.count ?? 0 > 20 ? "..." : "")
                    }
                }
            case .contact:
                if let contactsView = contactsView {
                    title = "Contact"
                    description = contactsView.getName() ?? ""
                }
            case .email:
                if let emailView = emailView {
                    title = "Email"
                    description = emailView.getEmail() ?? ""
                }
            case .website:
                if let websiteView = websiteView {
                    title = "Website"
                    description = websiteView.getURL() ?? ""
                }
            case .location:
                title = "Location"
                description = "Geo Coordinates"
            case .events:
                if let calendarView = calendarView {
                    title = "Calendar Event"
                    description = calendarView.getTitle() ?? ""
                }
            }
        } else if let socialType = codeType as? SocialQRCodeType {
            title = socialType.title
            switch socialType {
            case .facebook:
                description = facebookView?.getUsername() ?? ""
            case .instagram:
                description = instagramView?.getUsername() ?? ""
            case .tiktok:
                description = tiktokView?.getUsername() ?? ""
            case .x:
                description = xView?.getUsername() ?? ""
            case .youtube:
                description = youtubeView?.getUsername() ?? ""
            case .spotify:
                description = spotifyView?.getUsername() ?? ""
            case .whatsapp:
                description = whatsappView?.getPhoneNumber() ?? ""
            case .viber:
                description = viberView?.getPhoneNumber() ?? ""
            }
        } else if let barType = codeType as? BarCodeType {
            title = barType.title
            if let barCodeView = barCodeView {
                description = barCodeView.getContent() ?? ""
            }
        }
        
        resultVC.setTitleAndDescription(title: title, description: description)
        
        // Set up action handlers
        resultVC.setSaveAction { [weak self] in
            self?.saveImageToGallery(image)
        }
        
        resultVC.setShareAction { [weak self] in
            self?.shareImage(image)
        }
    }
    
    private func saveImageToGallery(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showErrorAlert(message: "Failed to save image: \(error.localizedDescription)")
        } else {
            let alert = UIAlertController(
                title: "Success",
                message: "Image saved to your photo library",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    private func shareImage(_ image: UIImage) {
        let activityViewController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(activityViewController, animated: true)
    }
    
    // MARK: - Prefilled Content Handling
    
    /// Apply prefilled content to the appropriate view based on code type
    private func applyPrefilledContent(_ content: String) {
        guard let codeType = currentCodeType else { return }
        
        if let qrCodeType = codeType as? QRCodeType {
            applyQRCodeContent(content, qrCodeType: qrCodeType)
        } else if let socialQRCodeType = codeType as? SocialQRCodeType {
            applySocialQRCodeContent(content, socialQRCodeType: socialQRCodeType)
        } else if let barCodeType = codeType as? BarCodeType {
            applyBarCodeContent(content, barCodeType: barCodeType)
        }
    }
    
    /// Handle QR code content based on QR code type
    private func applyQRCodeContent(_ content: String, qrCodeType: QRCodeType) {
        switch qrCodeType {
        case .wifi:
            // Let the WiFi view handle parsing the content
            wifiView?.parseAndPopulateFromContent(content)
            
        case .phone:
            // Let the Phone view handle parsing the content
            phoneView?.parseAndPopulateFromContent(content)
            
        case .text:
            // Let the Text view handle parsing the content
            textView?.parseAndPopulateFromContent(content)
            
        case .contact:
            // Let the Contacts view handle parsing the content
            contactsView?.parseAndPopulateFromContent(content)
            
        case .email:
            // Let the Email view handle parsing the content
            emailView?.parseAndPopulateFromContent(content)
            
        case .location:
            // Let the Location view handle parsing the content
            locationView?.parseAndPopulateFromContent(content)
            
        case .events:
            // Let the Calendar view handle parsing the content
            calendarView?.parseAndPopulateFromContent(content)
        case .website:
            // Let the Website view handle parsing the content
            websiteView?.parseAndPopulateFromContent(content)
        }
    }
    
    /// Handle social QR code content based on social media type
    private func applySocialQRCodeContent(_ content: String, socialQRCodeType: SocialQRCodeType) {
        switch socialQRCodeType {
        case .facebook:
            // Let the Facebook view handle parsing the content
            facebookView?.parseAndPopulateFromContent(content)
            
        case .instagram:
            // Let the Instagram view handle parsing the content
            instagramView?.parseAndPopulateFromContent(content)
            
        case .tiktok:
            // Let the TikTok view handle parsing the content
            tiktokView?.parseAndPopulateFromContent(content)
            
        case .x:
            // Let the X view handle parsing the content
            xView?.parseAndPopulateFromContent(content)
            
        case .youtube:
            // Let the YouTube view handle parsing the content
            youtubeView?.parseAndPopulateFromContent(content)
            
        case .spotify:
            // Let the Spotify view handle parsing the content
            spotifyView?.parseAndPopulateFromContent(content)
            
        case .whatsapp:
            // Let the WhatsApp view handle parsing the content
            whatsappView?.parseAndPopulateFromContent(content)
            
        case .viber:
            // Let the Viber view handle parsing the content
            viberView?.parseAndPopulateFromContent(content)
        }
    }
    
    /// Handle bar code content
    private func applyBarCodeContent(_ content: String, barCodeType: BarCodeType) {
        // Set barcode content
        barCodeView?.urlText = content
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Public Methods
    
    /// Configure the view controller with a specific Code type
    func configure(with codeType: CodeTypeProtocol) {
        currentCodeType = codeType
        self.navigationItem.title = codeType.title
        // Load the appropriate content view for the Code type
        loadContentView(for: codeType)
    }
    
    /// Load the appropriate content view based on Code type
    private func loadContentView(for codeType: CodeTypeProtocol) {
        let contentView = createContentView(for: codeType)
        replaceContentView(with: contentView)
    }
    
    /// Factory method to create content view for each Code type
    private func createContentView(for codeType: CodeTypeProtocol) -> UIView {
        if let qrCode = codeType as? QRCodeType {
            switch qrCode {
            case .text:
                return createTextView()
            case .wifi:
                return createWiFiView()
            case .phone:
                return createPhoneView()
            case .contact:
                return createContactView()
            case .email:
                return createEmailView()
            case .website:
                return createWebsiteView()
            case .location:
                return createLocationView()
            case .events:
                return createEventsView()
            }
        }
        
        if let socialCode = codeType as? SocialQRCodeType {
            switch socialCode {
            case .facebook:
                return createFacebookView()
            case .tiktok:
                return createTikTokView()
            case .instagram:
                return createInstagramView()
            case .x:
                return createXView()
            case .whatsapp:
                return createWhatsAppView()
            case .youtube:
                return createYouTubeView()
            case .spotify:
                return createSpotifyView()
            case .viber:
                return createViberView()
            }
        }
        
        if let barCodeType = codeType as? BarCodeType {
            return createBarcodeView(type: barCodeType)
        } else {
            return UIView()
        }
    }
    
    // MARK: - Content View Creation Methods (Placeholder implementations)
    
    private func createWiFiView() -> UIView {
        wifiView = WifiView()
        return wifiView!
    }
    
    private func createCalendarView() -> UIView {
        calendarView = CalendarView()
        return calendarView!
    }
    
    private func createPhoneView() -> UIView {
        phoneView = PhoneView()
        return phoneView!
    }
    
    private func createTextView() -> UIView {
        textView = TextView()
        return textView!
    }
    
    private func createContactView() -> UIView {
        contactsView = ContactsView()
        return contactsView!
    }
    
    private func createEmailView() -> UIView {
        emailView = EmailView()
        return emailView!
    }
    
    private func createWebsiteView() -> UIView {
        websiteView = WebsiteView()
        return websiteView!
    }
    
    private func createLocationView() -> UIView {
        locationView = LocationView()
        return locationView!
    }
    
    private func createEventsView() -> UIView {
        calendarView = CalendarView()
        return calendarView!
    }
    
    private func createTikTokView() -> UIView {
        tiktokView = TiktokView()
        return tiktokView!
    }
    
    private func createInstagramView() -> UIView {
        instagramView = InstagramView()
        return instagramView!
    }
    
    private func createFacebookView() -> UIView {
        facebookView = FacebookView()
        return facebookView!
    }
    
    private func createXView() -> UIView {
        xView = XView()
        return xView!
    }
    
    private func createWhatsAppView() -> UIView {
        whatsappView = WhatsappView()
        return whatsappView!
    }
    
    private func createYouTubeView() -> UIView {
        youtubeView = YoutubeView()
        return youtubeView!
    }
    
    private func createSpotifyView() -> UIView {
        spotifyView = SpotifyView()
        return spotifyView!
    }
    
    private func createViberView() -> UIView {
        viberView = ViberView()
        return viberView!
    }
    
    private func createBarcodeView(type: BarCodeType) -> UIView {
        barCodeView = BarCodeView()
        barCodeView?.type = type
        
        // Add test data based on barcode type
        switch type {
        case .code128:
            barCodeView?.urlText = "ABC-123456789"
        case .code39:
            barCodeView?.urlText = "CODE-39"
        case .code93:
            barCodeView?.urlText = "CODE-93"
        case .ean13:
            barCodeView?.urlText = "5901234123457"
        case .ean8:
            barCodeView?.urlText = "96385074"
        case .upca:
            barCodeView?.urlText = "042100005264"
        case .upce:
            barCodeView?.urlText = "01234565"
        case .itf:
            barCodeView?.urlText = "1234567890"
        case .pdf417:
            barCodeView?.urlText = "PDF417 Test Data"
        case .isbn:
            barCodeView?.urlText = "9781234567897"
        case .aztec:
            barCodeView?.urlText = "AZTEC-TEST-12345"
        case .dataMatrix:
            barCodeView?.urlText = "DATAMATRIX-12345"
        }
        
        return barCodeView!
    }
    
    /// Add custom content to the scroll view (in addition to replaceable content)
    func addContentToScrollView(_ view: UIView) {
        contentView.addSubview(view)
    }
    
    /// Set up content with auto layout in the scroll view (replaces replaceable content)
    func setupScrollableContent(with views: [UIView]) {
        // Remove existing content including replaceable content view
        replaceableContentView.removeFromSuperview()
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        var previousView: UIView?
        
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
            
            // Set up constraints
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            ])
            
            if let previousView = previousView {
                view.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 16).isActive = true
            } else {
                view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            }
            
            previousView = view
        }
        
        // Set bottom constraint for the last view
        if let lastView = previousView {
            lastView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        }
    }
    
    /// Replace the current content view with a new one
    private func replaceContentView(with newView: UIView) {
        // Remove any existing subviews
        replaceableContentView.subviews.forEach { $0.removeFromSuperview() }
        
        // Add the new view
        newView.translatesAutoresizingMaskIntoConstraints = false
        replaceableContentView.addSubview(newView)
        
        // Remove the placeholder height constraint if it exists
        placeholderHeightConstraint?.isActive = false
        
        // Set up constraints for the new view
        NSLayoutConstraint.activate([
            newView.topAnchor.constraint(equalTo: replaceableContentView.topAnchor),
            newView.leadingAnchor.constraint(equalTo: replaceableContentView.leadingAnchor),
            newView.trailingAnchor.constraint(equalTo: replaceableContentView.trailingAnchor),
            newView.bottomAnchor.constraint(equalTo: replaceableContentView.bottomAnchor)
        ])
    }
}
