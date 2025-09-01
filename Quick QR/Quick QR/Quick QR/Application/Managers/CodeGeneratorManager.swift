//
//  CodeGeneratorManager.swift
//  Quick QR
//
//  Created by Umair Afzal on 01/09/2025.
//

import Foundation
import UIKit
import CoreImage

class CodeGeneratorManager {
    // Singleton instance for easy access
    static let shared = CodeGeneratorManager()
    
    // MARK: - QR Code Generation
    
    func generateQRCode(from content: String, size: CGSize = CGSize(width: 300, height: 300),
                        color: UIColor = .black, backgroundColor: UIColor = .white) -> UIImage? {
        print("[CodeGeneratorManager] Generating QR code with content length: \(content.count)")
        
        // Create data from string
        guard let data = content.data(using: .utf8) else {
            print("[CodeGeneratorManager] Failed to create data from string")
            return nil 
        }
        
        // Create QR code filter
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
            print("[CodeGeneratorManager] Failed to create CIQRCodeGenerator filter")
            return nil 
        }
        qrFilter.setValue(data, forKey: "inputMessage")
        qrFilter.setValue("H", forKey: "inputCorrectionLevel") // High error correction
        
        // Get output image
        guard let ciImage = qrFilter.outputImage else {
            print("[CodeGeneratorManager] Failed to get output image from filter")
            return nil 
        }
        
        // Apply color filter if needed
        let coloredImage = applyColor(to: ciImage, color: color, backgroundColor: backgroundColor)
        print("[CodeGeneratorManager] Applied color filter successfully")
        
        // Scale the image to the desired size
        let scale = min(size.width / coloredImage.extent.width, size.height / coloredImage.extent.height)
        let scaledImage = coloredImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        print("[CodeGeneratorManager] Scaled image to size: \(size)")
        
        // Convert to UIImage
        let result = UIImage(ciImage: scaledImage)
        print("[CodeGeneratorManager] Successfully created UIImage from CIImage")
        return result
    }
    
    // MARK: - Barcode Generation
    
    func generateBarcode(content: String, type: BarCodeType, size: CGSize = CGSize(width: 300, height: 150)) -> UIImage? {
        // Get the appropriate barcode filter name based on type
        let filterName = getBarcodeFilterName(for: type)
        
        // Create data from string
        guard let data = content.data(using: .ascii) else { return nil }
        
        // Create barcode filter
        guard let barcodeFilter = CIFilter(name: filterName) else { return nil }
        
        // Configure filter based on type
        switch type {
        case .code128, .code39, .code93, .pdf417:
            barcodeFilter.setValue(data, forKey: "inputMessage")
        case .ean13, .ean8, .upca, .upce, .isbn, .itf:
            // These formats require specific digit formats
            if isValidForFormat(content, type: type) {
                barcodeFilter.setValue(data, forKey: "inputMessage")
            } else {
                return nil // Invalid input for this barcode type
            }
        }
        
        // Get output image
        guard let ciImage = barcodeFilter.outputImage else { return nil }
        
        // Scale the image to the desired size
        let scaleX = size.width / ciImage.extent.width
        let scaleY = size.height / ciImage.extent.height
        let scaledImage = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        // Convert to UIImage
        return UIImage(ciImage: scaledImage)
    }
    
    // MARK: - Helper Methods
    
    private func applyColor(to image: CIImage, color: UIColor, backgroundColor: UIColor) -> CIImage {
        // Create a colored mask
        let colorFilter = CIFilter(name: "CIFalseColor")!
        colorFilter.setValue(image, forKey: "inputImage")
        colorFilter.setValue(CIColor(color: color), forKey: "inputColor0")
        colorFilter.setValue(CIColor(color: backgroundColor), forKey: "inputColor1")
        
        return colorFilter.outputImage ?? image
    }
    
    private func getBarcodeFilterName(for type: BarCodeType) -> String {
        switch type {
        case .code128: return "CICode128BarcodeGenerator"
        case .pdf417: return "CIPDF417BarcodeGenerator"
        case .ean13, .isbn: return "CIEANBarcodeGenerator" // ISBN uses EAN format
        case .ean8: return "CIEANBarcodeGenerator"
        case .upca: return "CICode128BarcodeGenerator" // Core Image doesn't have UPC-A directly
        case .upce: return "CICode128BarcodeGenerator" // Core Image doesn't have UPC-E directly
        case .code39: return "CICode128BarcodeGenerator" // Fallback to Code128
        case .code93: return "CICode128BarcodeGenerator" // Fallback to Code128
        case .itf: return "CICode128BarcodeGenerator" // Fallback to Code128
        }
    }
    
    private func isValidForFormat(_ content: String, type: BarCodeType) -> Bool {
        // Validate input based on barcode type requirements
        switch type {
        case .ean13, .isbn:
            return content.count == 12 || content.count == 13
        case .ean8:
            return content.count == 7 || content.count == 8
        case .upca:
            return content.count == 11 || content.count == 12
        case .upce:
            return content.count == 7 || content.count == 8
        case .itf:
            return content.count % 2 == 0 // ITF requires even number of digits
        default:
            return true
        }
    }
    
    // MARK: - Specialized QR Code Generators
    
    func generateWifiQRCode(ssid: String, password: String, isWEP: Bool = false, size: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
        let authType = isWEP ? "WEP" : "WPA"
        let wifiString = "WIFI:S:\(ssid);T:\(authType);P:\(password);;"
        return generateQRCode(from: wifiString, size: size)
    }
    
    func generateContactQRCode(name: String, phone: String, email: String, address: String, size: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
        let vCardString = """
        BEGIN:VCARD
        VERSION:3.0
        N:\(name)
        TEL:\(phone)
        EMAIL:\(email)
        ADR:\(address)
        END:VCARD
        """
        return generateQRCode(from: vCardString, size: size)
    }
    
    func generateEmailQRCode(email: String, subject: String = "", body: String = "", size: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let emailString = "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)"
        return generateQRCode(from: emailString, size: size)
    }
    
    func generateLocationQRCode(latitude: Double, longitude: Double, size: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
        print("[CodeGeneratorManager] Generating location QR code with latitude: \(latitude), longitude: \(longitude)")
        let locationString = "geo:\(latitude),\(longitude)"
        let result = generateQRCode(from: locationString, size: size)
        if result == nil {
            print("[CodeGeneratorManager] Failed to generate location QR code")
        } else {
            print("[CodeGeneratorManager] Successfully generated location QR code")
        }
        return result
    }
    
    func generateCalendarEventQRCode(title: String, startDate: Date, endDate: Date, location: String = "", description: String = "", size: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
        print("[CodeGeneratorManager] Generating calendar event QR code")
        print("[CodeGeneratorManager] Title: \(title)")
        print("[CodeGeneratorManager] Start Date: \(startDate)")
        print("[CodeGeneratorManager] End Date: \(endDate)")
        print("[CodeGeneratorManager] Location: \(location)")
        print("[CodeGeneratorManager] Description: \(description)")
        
        // Check if this is an all-day event by seeing if the dates are at midnight
        let calendar = Calendar.current
        let isAllDay = calendar.component(.hour, from: startDate) == 0 && 
                       calendar.component(.minute, from: startDate) == 0 &&
                       calendar.component(.second, from: startDate) == 0 &&
                       calendar.component(.hour, from: endDate) == 0 && 
                       calendar.component(.minute, from: endDate) == 0 &&
                       calendar.component(.second, from: endDate) == 0
        
        // Use different date formats for all-day vs timed events
        let dateFormatter = DateFormatter()
        
        var startDateString: String
        var endDateString: String
        
        if isAllDay {
            // For all-day events, use date format without time component
            dateFormatter.dateFormat = "yyyyMMdd"
            startDateString = dateFormatter.string(from: startDate)
            endDateString = dateFormatter.string(from: endDate)
            
            print("[CodeGeneratorManager] All-day event detected")
            print("[CodeGeneratorManager] Formatted Start Date: \(startDateString)")
            print("[CodeGeneratorManager] Formatted End Date: \(endDateString)")
            
            // For all-day events in iCalendar format
            let eventString = """
            BEGIN:VEVENT
            SUMMARY:\(title)
            DTSTART;VALUE=DATE:\(startDateString)
            DTEND;VALUE=DATE:\(endDateString)
            LOCATION:\(location)
            DESCRIPTION:\(description)
            END:VEVENT
            """
            
            print("[CodeGeneratorManager] All-day Event String: \(eventString)")
            return generateQRCode(from: eventString, size: size)
            
        } else {
            // For timed events, include time component
            dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss"
            startDateString = dateFormatter.string(from: startDate)
            endDateString = dateFormatter.string(from: endDate)
            
            print("[CodeGeneratorManager] Timed event")
            print("[CodeGeneratorManager] Formatted Start Date: \(startDateString)")
            print("[CodeGeneratorManager] Formatted End Date: \(endDateString)")
            
            let eventString = """
            BEGIN:VEVENT
            SUMMARY:\(title)
            DTSTART:\(startDateString)
            DTEND:\(endDateString)
            LOCATION:\(location)
            DESCRIPTION:\(description)
            END:VEVENT
            """
            
            print("[CodeGeneratorManager] Event String: \(eventString)")
            
            let result = generateQRCode(from: eventString, size: size)
            if result == nil {
                print("[CodeGeneratorManager] Failed to generate calendar event QR code")
            } else {
                print("[CodeGeneratorManager] Successfully generated calendar event QR code")
            }
            
            return result
        }
    }
    
    func generateSocialQRCode(type: SocialQRCodeType, username: String, size: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
        let urlString: String
        
        switch type {
        case .facebook:
            urlString = "https://facebook.com/\(username)"
        case .instagram:
            urlString = "https://instagram.com/\(username)"
        case .tiktok:
            urlString = "https://tiktok.com/@\(username)"
        case .x:
            urlString = "https://x.com/\(username)"
        case .whatsapp:
            urlString = "https://wa.me/\(username)"
        case .youtube:
            urlString = "https://youtube.com/\(username)"
        case .spotify:
            urlString = "https://open.spotify.com/user/\(username)"
        case .viber:
            urlString = "viber://chat?number=\(username)"
        }
        
        return generateQRCode(from: urlString, size: size)
    }
}
