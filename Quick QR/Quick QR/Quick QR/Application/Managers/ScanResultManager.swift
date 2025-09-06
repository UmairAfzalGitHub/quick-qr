import UIKit
import AVFoundation
import Contacts
import ContactsUI

/// Manager class for handling scan result operations
class ScanResultManager {
    
    // MARK: - Singleton
    static let shared = ScanResultManager()
    
    private init() {}
    
    // MARK: - QR Code Generation
    
    /// Generate a QR code image from a string
    func generateQRCode(from string: String, size: CGFloat = 200) -> UIImage? {
        guard let data = string.data(using: .utf8) else { return nil }
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("H", forKey: "inputCorrectionLevel")
            
            if let outputImage = filter.outputImage {
                let transform = CGAffineTransform(scaleX: size / outputImage.extent.width, 
                                                 y: size / outputImage.extent.height)
                let scaledImage = outputImage.transformed(by: transform)
                
                if let cgImage = CIContext().createCGImage(scaledImage, from: scaledImage.extent) {
                    return UIImage(cgImage: cgImage)
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Data Extraction
    
    /// Parse SMS QR code data
    func parseSMSData(from smsData: String) -> (phoneNumber: String, message: String) {
        var phoneNumber = ""
        var message = ""
        
        if smsData.hasPrefix("SMSTO:") || smsData.hasPrefix("smsto:") {
            let smsComponents = smsData.replacingOccurrences(of: "SMSTO:", with: "", options: .caseInsensitive)
                                  .components(separatedBy: ":")
            if smsComponents.count >= 1 {
                phoneNumber = smsComponents[0].trimmingCharacters(in: .whitespacesAndNewlines)
                if smsComponents.count >= 2 {
                    message = smsComponents[1].trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        } else if smsData.hasPrefix("SMS:") || smsData.hasPrefix("sms:") {
            let smsComponents = smsData.replacingOccurrences(of: "sms:", with: "", options: .caseInsensitive)
                                  .components(separatedBy: ":")
            if smsComponents.count >= 1 {
                phoneNumber = smsComponents[0].trimmingCharacters(in: .whitespacesAndNewlines)
                if smsComponents.count >= 2 {
                    message = smsComponents[1].trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        } else {
            // Assume it's just a phone number
            phoneNumber = smsData.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return (phoneNumber, message)
    }
    
    /// Parse email QR code data
    func parseEmailData(from emailData: String) -> (email: String, subject: String, body: String) {
        var email = ""
        var subject = ""
        var body = ""
        
        if emailData.hasPrefix("mailto:") {
            // Format: mailto:email@example.com?subject=Subject&body=Body
            let mailtoComponents = emailData.components(separatedBy: "?")
            
            if mailtoComponents.count >= 1 {
                email = mailtoComponents[0].replacingOccurrences(of: "mailto:", with: "")
                
                if mailtoComponents.count >= 2 {
                    let queryItems = mailtoComponents[1].components(separatedBy: "&")
                    
                    for item in queryItems {
                        let keyValue = item.components(separatedBy: "=")
                        if keyValue.count == 2 {
                            let key = keyValue[0].lowercased()
                            let value = keyValue[1].removingPercentEncoding ?? keyValue[1]
                            
                            if key == "subject" {
                                subject = value
                            } else if key == "body" {
                                body = value
                            }
                        }
                    }
                }
            }
        } else {
            // Assume it's just an email address
            email = emailData
        }
        
        return (email, subject, body)
    }
    
    /// Parse location QR code data
    func parseLocationData(from locationData: String) -> (latitude: Double?, longitude: Double?) {
        if locationData.hasPrefix("geo:") {
            // Format: geo:latitude,longitude
            let coordinates = locationData.replacingOccurrences(of: "geo:", with: "")
            let parts = coordinates.components(separatedBy: ",")
            
            if parts.count >= 2 {
                let latitude = Double(parts[0])
                let longitude = Double(parts[1])
                return (latitude, longitude)
            }
        }
        
        return (nil, nil)
    }
    
    /// Extract a value from a string using a key (for formats like WIFI:S:name;T:WPA;P:password;)
    func extractValue(from string: String, key: String) -> String? {
        guard let range = string.range(of: key) else { return nil }
        
        let start = range.upperBound
        let substring = string[start...]
        
        if let endRange = substring.range(of: ";") {
            return String(substring[..<endRange.lowerBound])
        } else {
            return String(substring)
        }
    }
    
    /// Extract a value from a vCard string
    func extractVCardValue(from string: String, key: String) -> String? {
        // Split the string into lines for more accurate parsing
        let lines = string.components(separatedBy: .newlines)
        
        // Find the line that starts with the key (case insensitive)
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Check if line starts with the key (case insensitive)
            if trimmedLine.lowercased().hasPrefix(key.lowercased()) {
                // Extract the value part after the key
                let keyRange = trimmedLine.range(of: key, options: .caseInsensitive)
                if let upperBound = keyRange?.upperBound {
                    let value = trimmedLine[upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
                    return value.isEmpty ? nil : value
                }
            }
        }
        
        return nil
    }
    
    /// Extract username from social media URL
    func extractUsername(from url: String, for type: SocialQRCodeType) -> String? {
        guard let url = URL(string: url) else { return nil }
        
        let pathComponents = url.pathComponents.filter { !$0.isEmpty && $0 != "/" }
        
        if !pathComponents.isEmpty {
            return pathComponents.last
        }
        
        return nil
    }
    
    /// Get raw data from scan result
    func getRawData(from scanResult: ScanDataParser.ScanResult?) -> String? {
        guard let scanResult = scanResult else { return nil }
        
        switch scanResult {
        case .qrCode(_, let data):
            return data
        case .socialQR(_, let data):
            return data
        case .barcode(_, let data, _):
            return data
        case .unknown(let data):
            return data
        }
    }
    
    // MARK: - URL Handling
    
    /// Open a URL with proper error handling
    func openURL(_ urlString: String, completion: @escaping (Bool, String?) -> Void) {
        // Make sure URL has proper scheme if it's a web URL
        var processedURLString = urlString
        if !processedURLString.lowercased().hasPrefix("http://") && 
           !processedURLString.lowercased().hasPrefix("https://") &&
           !processedURLString.lowercased().hasPrefix("tel:") &&
           !processedURLString.lowercased().hasPrefix("mailto:") &&
           !processedURLString.lowercased().hasPrefix("sms:") &&
           !processedURLString.lowercased().hasPrefix("geo:") {
            processedURLString = "https://" + processedURLString
        }
        
        if let url = URL(string: processedURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: { success in
                if success {
                    completion(true, nil)
                } else {
                    completion(false, "Could not open URL: \(processedURLString)")
                }
            })
        } else {
            completion(false, "Invalid URL format")
        }
    }
    
    /// Open location in Maps app
    func openLocation(from locationData: String, completion: @escaping (Bool, String?) -> Void) {
        if locationData.hasPrefix("geo:") {
            // Format: geo:latitude,longitude
            let coordinates = locationData.replacingOccurrences(of: "geo:", with: "")
            let parts = coordinates.components(separatedBy: ",")
            
            if parts.count >= 2, let latitude = Double(parts[0]), let longitude = Double(parts[1]) {
                // Create Apple Maps URL
                let mapURL = "https://maps.apple.com/?ll=\(latitude),\(longitude)&q=\(latitude),\(longitude)"
                
                if let url = URL(string: mapURL) {
                    UIApplication.shared.open(url, options: [:], completionHandler: { success in
                        if success {
                            completion(true, nil)
                        } else {
                            completion(false, "Could not open Maps app")
                        }
                    })
                } else {
                    completion(false, "Could not create Maps URL")
                }
            } else {
                completion(false, "Invalid coordinates format")
            }
        } else {
            // Try to open as regular URL
            openURL(locationData, completion: completion)
        }
    }
    
    /// Open email client with email data
    func openEmail(from emailData: String, completion: @escaping (Bool, String?) -> Void) {
        var email = emailData
        if !email.hasPrefix("mailto:") {
            email = "mailto:" + email
        }
        
        // Properly encode the email URL
        if let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: encodedEmail) {
            UIApplication.shared.open(url, options: [:], completionHandler: { success in
                if success {
                    completion(true, nil)
                } else {
                    completion(false, "Could not open email client")
                }
            })
        } else {
            completion(false, "Invalid email format")
        }
    }
    
    /// Open SMS app with phone number and message
    func openSMS(from smsData: String, completion: @escaping (Bool, String?) -> Void) {
        // Parse SMS data
        var phoneNumber = ""
        var message = ""
        
        if smsData.hasPrefix("SMSTO:") || smsData.hasPrefix("smsto:") {
            let smsComponents = smsData.replacingOccurrences(of: "SMSTO:", with: "", options: .caseInsensitive)
                                  .components(separatedBy: ":")
            if smsComponents.count >= 1 {
                phoneNumber = smsComponents[0].trimmingCharacters(in: .whitespacesAndNewlines)
                if smsComponents.count >= 2 {
                    message = smsComponents[1].trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        } else if smsData.hasPrefix("SMS:") || smsData.hasPrefix("sms:") {
            let smsComponents = smsData.replacingOccurrences(of: "sms:", with: "", options: .caseInsensitive)
                                  .components(separatedBy: ":")
            if smsComponents.count >= 1 {
                phoneNumber = smsComponents[0].trimmingCharacters(in: .whitespacesAndNewlines)
                if smsComponents.count >= 2 {
                    message = smsComponents[1].trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
        
        // Create SMS URL
        if !phoneNumber.isEmpty {
            // URL encode the message
            let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let smsURL = "sms:\(phoneNumber)" + (!encodedMessage.isEmpty ? "&body=\(encodedMessage)" : "")
            
            if let url = URL(string: smsURL) {
                UIApplication.shared.open(url, options: [:], completionHandler: { success in
                    if success {
                        completion(true, nil)
                    } else {
                        completion(false, "Could not open SMS app")
                    }
                })
            } else {
                completion(false, "Invalid SMS format")
            }
        } else {
            completion(false, "No phone number found")
        }
    }
    
    /// Open phone app for calling
    func openPhoneCall(from phoneData: String, completion: @escaping (Bool, String?) -> Void) {
        let phoneNumber = phoneData.replacingOccurrences(of: "tel:", with: "")
            .replacingOccurrences(of: "telprompt:", with: "")
        
        if let url = URL(string: "tel://\(phoneNumber)") {
            UIApplication.shared.open(url, options: [:], completionHandler: { success in
                if success {
                    completion(true, nil)
                } else {
                    completion(false, "Could not open phone app")
                }
            })
        } else {
            completion(false, "Invalid phone number format")
        }
    }
    
    /// Search product by barcode
    func searchProduct(barcode: String, completion: @escaping (Bool, String?) -> Void) {
        if let encodedQuery = barcode.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "https://www.google.com/search?q=\(encodedQuery)") {
            UIApplication.shared.open(url, options: [:], completionHandler: { success in
                if success {
                    completion(true, nil)
                } else {
                    completion(false, "Could not open search")
                }
            })
        } else {
            completion(false, "Could not create search URL")
        }
    }
    
    // MARK: - Actions
    
    /// Save QR code image to photo library
    func saveQRCodeImage(_ image: UIImage?, completion: @escaping (Bool, Error?) -> Void) {
        guard let image = image else {
            completion(false, nil)
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        completion(true, nil)
    }
    
    /// Share QR code image
    func shareQRCode(_ image: UIImage?, from viewController: UIViewController) {
        guard let image = image else { return }
        
        let activityViewController = UIActivityViewController(activityItems: ["Check this out", image], applicationActivities: nil)
        viewController.present(activityViewController, animated: true)
    }
    
    /// Save contact from vCard data
    func saveContact(from vCardData: String, completion: @escaping (Bool, Error?) -> Void) {
        // Request contact access
        let contactStore = CNContactStore()
        contactStore.requestAccess(for: .contacts) { granted, error in
            if !granted {
                completion(false, error)
                return
            }
            
            // Parse vCard data
            guard let data = vCardData.data(using: .utf8) else {
                completion(false, nil)
                return
            }
            
            do {
                let contacts = try CNContactVCardSerialization.contacts(with: data)
                if let contact = contacts.first {
                    // Create a mutable copy of the contact
                    let mutableContact = contact.mutableCopy() as! CNMutableContact
                    
                    // Create a save request
                    let saveRequest = CNSaveRequest()
                    saveRequest.add(mutableContact, toContainerWithIdentifier: nil)
                    
                    do {
                        try contactStore.execute(saveRequest)
                        completion(true, nil)
                    } catch {
                        completion(false, error)
                    }
                } else {
                    completion(false, nil)
                }
            } catch {
                completion(false, error)
            }
        }
    }
    
    /// Save contact with user feedback
    func handleSaveContact(from vCardData: String, on viewController: UIViewController) {
        saveContact(from: vCardData) { [weak self] success, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if success {
                    self.showToast(message: "Contact saved successfully", on: viewController.view)
                } else if let error = error {
                    self.showToast(message: "Error saving contact: \(error.localizedDescription)", on: viewController.view)
                } else {
                    self.showToast(message: "Could not save contact", on: viewController.view)
                }
            }
        }
    }
    
    /// Connect to WiFi network
    func connectToWifi(from wifiData: String) -> (ssid: String?, password: String?) {
        // Extract SSID and password from WiFi QR code
        // Format: WIFI:S:<SSID>;T:<Authentication>;P:<Password>;;
        
        guard let ssidRange = wifiData.range(of: "S:"),
              let typeRange = wifiData.range(of: "T:"),
              let passwordRange = wifiData.range(of: "P:") else {
            return (nil, nil)
        }
        
        let ssidStart = wifiData.index(ssidRange.upperBound, offsetBy: 0)
        let ssidEnd = wifiData.index(typeRange.lowerBound, offsetBy: -1)
        let ssid = String(wifiData[ssidStart..<ssidEnd]).replacingOccurrences(of: ";", with: "")
        
        let passwordStart = wifiData.index(passwordRange.upperBound, offsetBy: 0)
        var passwordEnd = wifiData.endIndex
        if let semicolonRange = wifiData[passwordStart...].range(of: ";") {
            passwordEnd = semicolonRange.lowerBound
        }
        let password = String(wifiData[passwordStart..<passwordEnd])
        
        return (ssid, password)
    }
    
    /// Handle WiFi connection with user feedback
    func handleWifiConnection(from wifiData: String, completion: @escaping (Bool, String) -> Void) {
        let wifiInfo = connectToWifi(from: wifiData)
        
        if let ssid = wifiInfo.ssid, let password = wifiInfo.password {
            // On iOS, we can't programmatically connect to WiFi networks
            // Copy password to clipboard for user convenience
            UIPasteboard.general.string = password
            completion(true, "Network: \(ssid)\nPassword copied to clipboard")
        } else {
            completion(false, "Invalid WiFi QR code format")
        }
    }
    
    // MARK: - UI Helpers
    
    /// Create an action button for the scan result view
    func makeActionButton(icon: UIImage?, title: String) -> UIView {
        // Create a container view that will be tappable
        let container = UIView()
        container.backgroundColor = .clear
        
        // Create a vertical stack for icon and label
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)
        
        // Add icon image view
        let iconView = UIImageView(image: icon)
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = UIColor(named: "AccentColor")
        iconView.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(iconView)
        
        // Add title label
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        stack.addArrangedSubview(label)
        
        // Set constraints
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // Set accessibility label for the container (used for tap handling)
        container.accessibilityLabel = title
        
        return container
    }
    
    /// Create an info row with title, value and optional copy button
    func makeInfoRow(title: String,
                     value: String,
                     showsButton: Bool = false,
                     buttonImage: UIImage? = UIImage(systemName: "doc.on.doc"),
                     buttonAction: Selector? = nil,
                     target: Any? = nil) -> UIView {
        // Container view
        let container = UIView()
        container.backgroundColor = .clear
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        titleLabel.textColor = UIColor(named: "TextSecondary")
        titleLabel.numberOfLines = 0
        
        // Value label
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        valueLabel.textColor = UIColor(named: "TextPrimary")
        valueLabel.numberOfLines = 0
        valueLabel.textAlignment = .right
        
        // Add to container
        container.addSubview(titleLabel)
        container.addSubview(valueLabel)
        
        // Set up constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add copy button if needed
        if showsButton {
            let button = UIButton(type: .system)
            button.setImage(buttonImage, for: .normal)
            button.tintColor = UIColor(named: "AccentColor")
            
            // Add tap action with provided selector or default
            if let action = buttonAction, let target = target {
                button.addTarget(target, action: action, for: .touchUpInside)
            } else {
//                // Fallback to default if no selector provided
//                button.addTarget(nil, action: #selector(ScanResultViewController.copyButtonTapped(_:)), for: .touchUpInside)
            }
            
            // Set accessibility label for the button to identify it later
            button.accessibilityLabel = value
            
            container.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
                titleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
                titleLabel.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.35),
                
                valueLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
                valueLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
                valueLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
                
                button.leadingAnchor.constraint(equalTo: valueLabel.trailingAnchor, constant: 8),
                button.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                button.widthAnchor.constraint(equalToConstant: 24),
                button.heightAnchor.constraint(equalToConstant: 24)
            ])
            
            // Adjust value label width to accommodate button
            valueLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        } else {
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
                titleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
                titleLabel.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.35),
                
                valueLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
                valueLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
                valueLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
                valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor)
            ])
        }
        
        return container
    }
    
    /// Show toast message
    func showToast(message: String, on view: UIView) {
        let toastContainer = UIView()
        toastContainer.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastContainer.layer.cornerRadius = 12
        toastContainer.clipsToBounds = true
        toastContainer.alpha = 0.0
        
        let toastLabel = UILabel()
        toastLabel.textColor = .white
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.numberOfLines = 0
        
        toastContainer.addSubview(toastLabel)
        view.addSubview(toastContainer)
        
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            toastContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            toastContainer.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8),
            
            toastLabel.leadingAnchor.constraint(equalTo: toastContainer.leadingAnchor, constant: 12),
            toastLabel.topAnchor.constraint(equalTo: toastContainer.topAnchor, constant: 8),
            toastLabel.trailingAnchor.constraint(equalTo: toastContainer.trailingAnchor, constant: -12),
            toastLabel.bottomAnchor.constraint(equalTo: toastContainer.bottomAnchor, constant: -8)
        ])
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            toastContainer.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 2.0, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0.0
            }, completion: { _ in
                toastContainer.removeFromSuperview()
            })
        })
    }
}
