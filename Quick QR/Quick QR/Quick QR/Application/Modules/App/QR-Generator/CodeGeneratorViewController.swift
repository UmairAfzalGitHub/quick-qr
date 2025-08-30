//
//  CodeGeneratorViewController.swift
//  Quick QR
//
//  Created by Haider Rathore on 28/08/2025.
//

import UIKit


class CodeGeneratorViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let actionButton = AppButtonView()
    private let adContainerView = UIView()

    private var wifiView: WifiView?
    private var emailView: EmailView?
    private var websiteView: WebsiteView?
    private var phoneView: PhoneView?
    private var textView: TextView?
    private var contactsView: ContactsView?
    private var locationView: LocationView?
    private var tiktokView: TiktokView?
    private var instagramView: InstagramView?
    private var facebookView: FacebookView?
    private var xView: XView?
    private var spotifyView: SpotifyView?
    private var youtubeView: YoutubeView?
    private var whatsappView: WhatsappView?
    private var viberView: ViberView?
    private var barCodeView: BarCodeView?
    private var calendarView: CalendarView?

    // MARK: - Content View (to be replaced)
    private let replaceableContentView = UIView()
    private var placeholderHeightConstraint: NSLayoutConstraint?

    // MARK: - Code Type
    var currentCodeType: CodeTypeProtocol?
    var buttonAction: (() -> Void)?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure(with: currentCodeType!)
        setupUI()
        setupConstraints()
        setupActions()
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
//        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
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
        // This will be implemented when creating specific view content extraction
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
        return createPlaceholderView(for: "Events", description: "Calendar event form will go here")
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
        return barCodeView!
    }
    
    /// Helper method to create placeholder views for each type
    private func createPlaceholderView(for type: String, description: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .systemBackground
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = type
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = description
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -40)
        ])
        
        return containerView
    }
    
    /// Get the current Code type
    func getCurrentCodeType() -> CodeTypeProtocol? {
        return currentCodeType
    }
    
    /// Replace the content view with a custom view from the previous screen
    func replaceContentView(with newView: UIView) {
        // Remove all subviews from the replaceable content view
        replaceableContentView.subviews.forEach { $0.removeFromSuperview() }
        
        // Remove the placeholder height constraint to allow dynamic sizing
        placeholderHeightConstraint?.isActive = false
        placeholderHeightConstraint = nil
        
        // Add the new view
        newView.translatesAutoresizingMaskIntoConstraints = false
        replaceableContentView.addSubview(newView)
        
        // Constraint the new view to fill the replaceable content view
        // The height will now be determined by the internal content of newView
        NSLayoutConstraint.activate([
            newView.topAnchor.constraint(equalTo: replaceableContentView.topAnchor),
            newView.leadingAnchor.constraint(equalTo: replaceableContentView.leadingAnchor),
            newView.trailingAnchor.constraint(equalTo: replaceableContentView.trailingAnchor),
            newView.bottomAnchor.constraint(equalTo: replaceableContentView.bottomAnchor)
        ])
        
        // Remove the border and background since content is loaded
        replaceableContentView.layer.borderWidth = 0
        replaceableContentView.backgroundColor = .clear
        
        // Force layout update to recalculate the scroll view's content size
        view.layoutIfNeeded()
    }
    
    /// Add custom content to the scroll view (in addition to replaceable content)
    func addContentToScrollView(_ view: UIView) {
        contentView.addSubview(view)
    }
    
    /// Set up content with auto layout in the scroll view (replaces replaceable content)
    func setupScrollableContent(with views: [UIView]) {
        // Remove existing content including replaceable content view
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        var previousView: UIView?
        
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
            
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ])
            
            if let previous = previousView {
                view.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 16).isActive = true
            } else {
                view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true
            }
            
            previousView = view
        }
        
        // Set content view height
        if let lastView = previousView {
            lastView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
        }
    }
    
    /// Replace the ad container with custom ad view
    func setAdView(_ adView: UIView) {
        adContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        adView.translatesAutoresizingMaskIntoConstraints = false
        adContainerView.addSubview(adView)
        
        NSLayoutConstraint.activate([
            adView.topAnchor.constraint(equalTo: adContainerView.topAnchor),
            adView.leadingAnchor.constraint(equalTo: adContainerView.leadingAnchor),
            adView.trailingAnchor.constraint(equalTo: adContainerView.trailingAnchor),
            adView.bottomAnchor.constraint(equalTo: adContainerView.bottomAnchor)
        ])
    }
    
    /// Get reference to scroll view for additional customization
    func getScrollView() -> UIScrollView {
        return scrollView
    }
    
    /// Get reference to content view for direct manipulation
    func getContentView() -> UIView {
        return contentView
    }
    
    /// Get reference to the replaceable content view
    func getReplaceableContentView() -> UIView {
        return replaceableContentView
    }
}
