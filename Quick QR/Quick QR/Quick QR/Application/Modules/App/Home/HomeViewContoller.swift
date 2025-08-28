//
//  HomeViewController.swift
//
//  Created by Haider Rathore on 27/08/2025.
//

import UIKit
import BetterSegmentedControl

// MARK: - QR Code Types Enum
enum QRCodeType: CaseIterable {
    case wifi, phone, text, contact, email, website, location, events
    
    var title: String {
        switch self {
        case .wifi: return "Wi-Fi"
        case .phone: return "Phone"
        case .text: return "Text"
        case .contact: return "Contact"
        case .email: return "Email"
        case .website: return "Website"
        case .location: return "Location"
        case .events: return "Events"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .wifi: return UIImage(named: "wifi-icon")
        case .phone: return UIImage(named: "phone-icon")
        case .text: return UIImage(named: "text-icon")
        case .contact: return UIImage(named: "contact-icon")
        case .email: return UIImage(named: "email-icon")
        case .website: return UIImage(named: "website-icon")
        case .location: return UIImage(named: "location-icon")
        case .events: return UIImage(named: "events-icon")
        }
    }
}

// MARK: - Social Media QR Types Enum
enum SocialQRCodeType: CaseIterable {
    case tiktok, instagram, facebook, x, whatsapp, youtube, spotify, viber
    
    var title: String {
        switch self {
        case .tiktok: return "TikTok"
        case .instagram: return "Instagram"
        case .facebook: return "Facebook"
        case .x: return "X"
        case .whatsapp: return "WhatsApp"
        case .youtube: return "Youtube"
        case .spotify: return "Spotify"
        case .viber: return "Viber"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .tiktok: return UIImage(named: "tiktok-icon")
        case .instagram: return UIImage(named: "insta-icon")
        case .facebook: return UIImage(named: "facebook-icon")
        case .x: return UIImage(named: "x-icon")
        case .whatsapp: return UIImage(named: "whatsapp-icon")
        case .youtube: return UIImage(named: "yt-icon")
        case .spotify: return UIImage(named: "spotify-icon")
        case .viber: return UIImage(named: "viber-icon")
        }
    }
}

// MARK: - Bar Code Types Enum
enum BarCodeType: CaseIterable {
    case isbn, ean8, upce, ean13, upca, code39, code93, code128, itf, pdf417
    
    var title: String {
        switch self {
        case .isbn: return "ISBN"
        case .ean8: return "EAN 8"
        case .upce: return "UPC E"
        case .ean13: return "EAN 13"
        case .upca: return "UPC A"
        case .code39: return "Code 39"
        case .code93: return "Code 93"
        case .code128: return "Code 128"
        case .itf: return "ITF"
        case .pdf417: return "PDF 417"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .isbn: return UIImage(named: "isbn-icon")
        case .ean8: return UIImage(named: "ean8-icon")
        case .upce: return UIImage(named: "upce-icon")
        case .ean13: return UIImage(named: "ean13-icon")
        case .upca: return UIImage(named: "upca-icon")
        case .code39: return UIImage(named: "code39-icon")
        case .code93: return UIImage(named: "code93-icon")
        case .code128: return UIImage(named: "code128-icon")
        case .itf: return UIImage(named: "itf-icon")
        case .pdf417: return UIImage(named: "pdf417-icon")
        }
    }
}

// MARK: - CollectionView Cell
class QRTypeCell: UICollectionViewCell {
    static let identifier = "QRTypeCell"
    
    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .black
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        lbl.textColor = .textPrimary
        return lbl
    }()
    
    private let boxView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 11
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.appBorderDark.cgColor
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(boxView)
        contentView.addSubview(titleLabel)
        boxView.addSubview(iconView)
        
        boxView.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Box constraints
            boxView.topAnchor.constraint(equalTo: contentView.topAnchor),
            boxView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            boxView.widthAnchor.constraint(equalToConstant: 60),
            boxView.heightAnchor.constraint(equalToConstant: 60),
            
            // Icon inside box
            iconView.centerXAnchor.constraint(equalTo: boxView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: boxView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),
            
            // Title below box
            titleLabel.topAnchor.constraint(equalTo: boxView.bottomAnchor, constant: 6),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(title: String, icon: UIImage?) {
        titleLabel.text = title
        iconView.image = icon
    }
}

// MARK: - Header View
class HeaderView: UICollectionReusableView {
    static let identifier = "HeaderView"
    
    private let label: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 16)
        lbl.textColor = .black
        return lbl
    }()
    
    var title: String? {
        didSet { label.text = title }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - HomeViewController
class HomeViewController: UIViewController {
    
    private let betterSegmentedControl: BetterSegmentedControl = {
        let control = BetterSegmentedControl(
            frame: CGRect.zero,
            segments: LabelSegment.segments(withTitles: ["QR Code", "Bar Code"],
                                          normalFont: UIFont.systemFont(ofSize: 16, weight: .medium),
                                          normalTextColor: UIColor.systemGray,
                                          selectedFont: UIFont.systemFont(ofSize: 16, weight: .medium),
                                          selectedTextColor: UIColor.white),
            options: [.backgroundColor(UIColor.systemGray6),
                     .indicatorViewBackgroundColor(UIColor.systemBlue),
                     .cornerRadius(27),
                     .animationSpringDamping(1.0),
                     .animationDuration(0.3)])
        
        control.setIndex(0) // Start with "QR Code" selected
        return control
    }()
    
    private var collectionView: UICollectionView!
    
    // Track current segment state
    private var isQRCodeSelected: Bool {
        return betterSegmentedControl.index == 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        title = "Choose Type"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.textPrimary,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
    }
    
    private func setupUI() {
        // Add Better Segmented Control
        view.addSubview(betterSegmentedControl)
        betterSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        // Add value changed action
        betterSegmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            betterSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            betterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            betterSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            betterSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
//            betterSegmentedControl.widthAnchor.constraint(equalToConstant: 200),
            betterSegmentedControl.heightAnchor.constraint(equalToConstant: 54)
        ])
        
        // Setup CollectionView
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 20
        layout.headerReferenceSize = CGSize(width: view.frame.width, height: 40)
        layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 20, right: 16)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(QRTypeCell.self, forCellWithReuseIdentifier: QRTypeCell.identifier)
        collectionView.register(HeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: HeaderView.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: betterSegmentedControl.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func segmentChanged(_ sender: BetterSegmentedControl) {
        // Reload collection view when segment changes
        collectionView.reloadData()
    }
}

// MARK: - QR Code Type Methods
extension HomeViewController {
    
    // MARK: - Regular QR Code Methods
    @objc private func handleWiFiQRCode() {
        print("Wi-Fi QR Code selected")
        // Navigate to Wi-Fi QR code creation screen
        // Example: navigationController?.pushViewController(WiFiQRViewController(), animated: true)
    }
    
    @objc private func handlePhoneQRCode() {
        print("Phone QR Code selected")
        // Navigate to phone QR code creation screen
    }
    
    @objc private func handleTextQRCode() {
        print("Text QR Code selected")
        // Navigate to text QR code creation screen
    }
    
    @objc private func handleContactQRCode() {
        print("Contact QR Code selected")
        // Navigate to contact QR code creation screen
    }
    
    @objc private func handleEmailQRCode() {
        print("Email QR Code selected")
        // Navigate to email QR code creation screen
    }
    
    @objc private func handleWebsiteQRCode() {
        print("Website QR Code selected")
        // Navigate to website QR code creation screen
    }
    
    @objc private func handleLocationQRCode() {
        print("Location QR Code selected")
        // Navigate to location QR code creation screen
    }
    
    @objc private func handleEventsQRCode() {
        print("Events QR Code selected")
        // Navigate to events QR code creation screen
    }
    
    // MARK: - Social Media QR Code Methods
    @objc private func handleTikTokQRCode() {
        print("TikTok QR Code selected")
        // Navigate to TikTok QR code creation screen
    }
    
    @objc private func handleInstagramQRCode() {
        print("Instagram QR Code selected")
        // Navigate to Instagram QR code creation screen
    }
    
    @objc private func handleFacebookQRCode() {
        print("Facebook QR Code selected")
        // Navigate to Facebook QR code creation screen
    }
    
    @objc private func handleXQRCode() {
        print("X QR Code selected")
        // Navigate to X QR code creation screen
    }
    
    @objc private func handleWhatsAppQRCode() {
        print("WhatsApp QR Code selected")
        // Navigate to WhatsApp QR code creation screen
    }
    
    @objc private func handleYouTubeQRCode() {
        print("YouTube QR Code selected")
        // Navigate to YouTube QR code creation screen
    }
    
    @objc private func handleSpotifyQRCode() {
        print("Spotify QR Code selected")
        // Navigate to Spotify QR code creation screen
    }
    
    @objc private func handleViberQRCode() {
        print("Viber QR Code selected")
        // Navigate to Viber QR code creation screen
    }
    
    // MARK: - Bar Code Methods
    @objc private func handleEAN8BarCode() {
        print("EAN-8 Bar Code selected")
        // Navigate to EAN-8 bar code creation screen
    }
    
    @objc private func handleEAN13BarCode() {
        print("EAN-13 Bar Code selected")
        // Navigate to EAN-13 bar code creation screen
    }
    
    @objc private func handleUPCABarCode() {
        print("UPC-A Bar Code selected")
        // Navigate to UPC-A bar code creation screen
    }
    
    @objc private func handleUPCEBarCode() {
        print("UPC-E Bar Code selected")
        // Navigate to UPC-E bar code creation screen
    }
    
    @objc private func handleCode39BarCode() {
        print("Code 39 Bar Code selected")
        // Navigate to Code 39 bar code creation screen
    }
    
    @objc private func handleCode93BarCode() {
        print("Code 93 Bar Code selected")
        // Navigate to Code 93 bar code creation screen
    }
    
    @objc private func handleCode128BarCode() {
        print("Code 128 Bar Code selected")
        // Navigate to Code 128 bar code creation screen
    }
    
    @objc private func handlePDF417BarCode() {
        print("PDF 417 Bar Code selected")
        // Navigate to PDF 417 bar code creation screen
    }
    
    @objc private func handleITFBarCode() {
        print("ITF Bar Code selected")
        // Navigate to ITF bar code creation screen
    }
    
    @objc private func handleISBNBarCode() {
        print("ISBN Bar Code selected")
        // Navigate to ISBN bar code creation screen
    }
}

// MARK: - CollectionView DataSource + Delegate
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return isQRCodeSelected ? 2 : 1 // QR Code has 2 sections, Bar Code has 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isQRCodeSelected {
            return section == 0 ? QRCodeType.allCases.count : SocialQRCodeType.allCases.count
        } else {
            return BarCodeType.allCases.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: QRTypeCell.identifier, for: indexPath) as? QRTypeCell else {
            return UICollectionViewCell()
        }
        
        if isQRCodeSelected {
            if indexPath.section == 0 {
                let type = QRCodeType.allCases[indexPath.item]
                cell.configure(title: type.title, icon: type.icon)
            } else {
                let type = SocialQRCodeType.allCases[indexPath.item]
                cell.configure(title: type.title, icon: type.icon)
            }
        } else {
            let type = BarCodeType.allCases[indexPath.item]
            cell.configure(title: type.title, icon: type.icon)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: HeaderView.identifier, for: indexPath) as? HeaderView else {
            return UICollectionReusableView()
        }
        
        if isQRCodeSelected {
            header.title = indexPath.section == 0 ? "Choose QR Code Type" : "Choose Social Media QR Code Type"
        } else {
            header.title = "Choose Bar Code Type"
        }
        return header
    }
    
    // MARK: - Cell Selection
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if isQRCodeSelected {
            if indexPath.section == 0 {
                // Regular QR Code Types
                let type = QRCodeType.allCases[indexPath.item]
                switch type {
                case .wifi:
                    handleWiFiQRCode()
                case .phone:
                    handlePhoneQRCode()
                case .text:
                    handleTextQRCode()
                case .contact:
                    handleContactQRCode()
                case .email:
                    handleEmailQRCode()
                case .website:
                    handleWebsiteQRCode()
                case .location:
                    handleLocationQRCode()
                case .events:
                    handleEventsQRCode()
                }
            } else {
                // Social Media QR Code Types
                let type = SocialQRCodeType.allCases[indexPath.item]
                switch type {
                case .tiktok:
                    handleTikTokQRCode()
                case .instagram:
                    handleInstagramQRCode()
                case .facebook:
                    handleFacebookQRCode()
                case .x:
                    handleXQRCode()
                case .whatsapp:
                    handleWhatsAppQRCode()
                case .youtube:
                    handleYouTubeQRCode()
                case .spotify:
                    handleSpotifyQRCode()
                case .viber:
                    handleViberQRCode()
                }
            }
        } else {
            // Bar Code Types
            let type = BarCodeType.allCases[indexPath.item]
            switch type {
            case .isbn:
                handleISBNBarCode()
            case .ean8:
                handleEAN8BarCode()
            case .upce:
                handleUPCEBarCode()
            case .ean13:
                handleEAN13BarCode()
            case .upca:
                handleUPCABarCode()
            case .code39:
                handleCode39BarCode()
            case .code93:
                handleCode93BarCode()
            case .code128:
                handleCode128BarCode()
            case .itf:
                handleITFBarCode()
            case .pdf417:
                handlePDF417BarCode()
            }
        }
    }
    
    // Adjust cell size to fit 4 per row
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing: CGFloat = 16 * 3 + 16 * 2 // (3 interitem gaps + left+right insets)
        let availableWidth = collectionView.bounds.width - totalSpacing
        let width = availableWidth / 4
        return CGSize(width: width, height: 90) // 60 box + 6 gap + label
    }
}
