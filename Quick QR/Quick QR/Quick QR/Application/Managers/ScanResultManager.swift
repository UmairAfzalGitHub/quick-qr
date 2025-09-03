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
        
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        viewController.present(activityViewController, animated: true)
    }
    
    /// Save contact from vCard data
    func saveContact(from vCardData: String, completion: @escaping (Bool, Error?) -> Void) {
        // Request contact access
        let contactStore = CNContactStore()
        contactStore.requestAccess(for: .contacts) { granted, error in
            if granted {
                // Create a new contact from vCard data
                do {
                    let data = vCardData.data(using: .utf8)!
                    let contacts = try CNContactVCardSerialization.contacts(with: data)
                    
                    if let contact = contacts.first {
                        // Create a mutable copy to save
                        let mutableContact = contact.mutableCopy() as! CNMutableContact
                        
                        // Create a save request
                        let saveRequest = CNSaveRequest()
                        saveRequest.add(mutableContact, toContainerWithIdentifier: nil)
                        
                        try contactStore.execute(saveRequest)
                        completion(true, nil)
                    } else {
                        completion(false, NSError(domain: "com.quickqr.error", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Could not parse contact information"]))
                    }
                } catch {
                    completion(false, error)
                }
            } else {
                completion(false, error ?? NSError(domain: "com.quickqr.error", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Contact access denied"]))
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
    
    // MARK: - UI Helpers
    
    /// Show toast message
    func showToast(message: String, on view: UIView) {
        let toastContainer = UIView()
        toastContainer.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastContainer.layer.cornerRadius = 10
        toastContainer.clipsToBounds = true
        
        let toastLabel = UILabel()
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.numberOfLines = 0
        
        toastContainer.addSubview(toastLabel)
        view.addSubview(toastContainer)
        
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            toastContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            toastContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            toastContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            toastLabel.topAnchor.constraint(equalTo: toastContainer.topAnchor, constant: 8),
            toastLabel.leadingAnchor.constraint(equalTo: toastContainer.leadingAnchor, constant: 12),
            toastLabel.trailingAnchor.constraint(equalTo: toastContainer.trailingAnchor, constant: -12),
            toastLabel.bottomAnchor.constraint(equalTo: toastContainer.bottomAnchor, constant: -8)
        ])
        
        UIView.animate(withDuration: 0.3, delay: 2.0, options: .curveEaseOut, animations: {
            toastContainer.alpha = 0.0
        }, completion: { _ in
            toastContainer.removeFromSuperview()
        })
    }
}
