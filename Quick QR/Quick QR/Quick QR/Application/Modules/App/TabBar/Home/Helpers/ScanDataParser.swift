//
//  ScanDataParser.swift
//  Quick QR
//
//  Created by Cascade on 03/09/2025.
//

import Foundation
import AVFoundation
import UIKit

/// Utility class to parse scan data and determine its type
class ScanDataParser {
    
    /// Represents the result of parsing scan data
    enum ScanResult {
        case qrCode(type: QRCodeType, data: String)
        case socialQR(type: SocialQRCodeType, data: String)
        case barcode(type: BarCodeType, data: String, symbology: AVMetadataObject.ObjectType)
        case unknown(data: String)
        
        var title: String {
            switch self {
            case .qrCode(let type, _):
                return type.title
            case .socialQR(let type, _):
                return type.title
            case .barcode(let type, _, _):
                return type.title
            case .unknown:
                return "Unknown"
            }
        }
        
        var icon: UIImage? {
            switch self {
            case .qrCode(let type, _):
                return type.icon
            case .socialQR(let type, _):
                return type.icon
            case .barcode(let type, _, _):
                return type.icon
            case .unknown:
                return UIImage(named: "text-icon") // Default to text icon
            }
        }
    }
    
    /// Parse the scanned string data and determine its type
    /// - Parameters:
    ///   - data: The scanned string data
    ///   - symbology: The AVMetadataObject.ObjectType of the scanned code (if available)
    /// - Returns: A ScanResult representing the parsed data
    static func parse(data: String, symbology: AVMetadataObject.ObjectType? = nil) -> ScanResult {
        // Lowercase the data for case-insensitive matching
        let lowercasedData = data.lowercased()
        
        // Check if it's a barcode type based on symbology
        if let symbology = symbology, isBarcode(symbology: symbology) {
            let barcodeType = determineBarcodeType(symbology: symbology)
            return .barcode(type: barcodeType, data: data, symbology: symbology)
        }
        
        // Check if it's a social media QR code
        if let socialType = determineSocialQRType(from: lowercasedData) {
            return .socialQR(type: socialType, data: data)
        }
        
        // Check if it's a standard QR code type
        if let qrType = determineQRCodeType(from: lowercasedData) {
            return .qrCode(type: qrType, data: data)
        }
        
        // If we can't determine the type, return unknown
        return .unknown(data: data)
    }
    
    // MARK: - Private Helper Methods
    
    /// Determine if the symbology represents a barcode
    private static func isBarcode(symbology: AVMetadataObject.ObjectType) -> Bool {
        // QR codes are handled separately as they can contain various data types
        if symbology == .qr {
            return false
        }
        
        let barcodeTypes: [AVMetadataObject.ObjectType] = [
            .ean8, .ean13, .pdf417, .aztec, .code39, .code93, .code128,
            .dataMatrix, .interleaved2of5, .itf14, .upce
        ]
        return barcodeTypes.contains(symbology)
    }
    
    /// Determine the barcode type based on the symbology
    private static func determineBarcodeType(symbology: AVMetadataObject.ObjectType) -> BarCodeType {
        switch symbology {
        case .ean8:
            return .ean8
        case .ean13:
            return .ean13
        case .pdf417:
            return .pdf417
        case .code39:
            return .code39
        case .code93:
            return .code93
        case .code128:
            return .code128
        case .dataMatrix:
            return .dataMatrix
        case .aztec:
            return .aztec
        case .interleaved2of5, .itf14:
            return .itf
        case .upce:
            return .upce
        default:
            // Default to Code128 for unknown barcode types
            return .code128
        }
    }
    
    /// Determine the social QR code type from the scanned data
    private static func determineSocialQRType(from data: String) -> SocialQRCodeType? {
        // Check URL schemes first
        for type in SocialQRCodeType.allCases {
            for scheme in type.schemes {
                if data.hasPrefix("\(scheme):") {
                    return type
                }
            }
        }
        
        // Check URL suffixes
        let url = URL(string: data)
        let host = url?.host?.lowercased() ?? data.lowercased()
        for type in SocialQRCodeType.allCases {
            for suffix in type.suffex {
                if host.contains(suffix) {
                    return type
                }
            }
        }
        
        return nil
    }
    
    /// Determine the QR code type from the scanned data
    private static func determineQRCodeType(from data: String) -> QRCodeType? {
        // Check prefixes
        for type in QRCodeType.allCases {
            for prefix in type.prefixes {
                if data.hasPrefix(prefix) {
                    return type
                }
            }
        }
        
        // Check URL schemes
        let url = URL(string: data)
        if let scheme = url?.scheme?.lowercased() {
            for type in QRCodeType.allCases {
                if type.schemes.contains(scheme) {
                    return type
                }
            }
        }
        
        // Check for contained strings
        for type in QRCodeType.allCases {
            for substring in type.contains {
                if data.contains(substring) {
                    return type
                }
            }
        }
        
        // Check URL suffixes
        let host = url?.host?.lowercased() ?? data.lowercased()
        for type in QRCodeType.allCases {
            for suffix in type.suffex {
                if host.contains(suffix) {
                    return type
                }
            }
        }
        
        // If it looks like a URL but wasn't matched above, it's probably a website
        if data.hasPrefix("http://") || data.hasPrefix("https://") || 
           data.contains("www.") || data.contains(".com") || data.contains(".org") || 
           data.contains(".net") || data.contains(".io") {
            return .website
        }
        
        // Default to text if we can't determine the type
        return .text
    }
}
