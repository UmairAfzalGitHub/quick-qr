//
//  BarCodeType.swift
//  Quick QR
//
//  Created by Haider Rathore on 28/08/2025.
//

import UIKit
import AVFoundation

protocol CodeTypeProtocol {
    var title: String { get }
    var icon: UIImage? { get }
    // URL or text matching helpers
    var prefixes: [String] { get }   // lowercase prefixes to match with hasPrefix
    var schemes: [String] { get }    // lowercase URL schemes to match
    var contains: [String] { get }   // lowercase substrings to match with contains
    var suffex: [String] { get }     // lowercase host suffixes to match (keeping project spelling)
}

enum BarCodeType: CaseIterable, CodeTypeProtocol {
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
    
    // Not used for 1D barcodes in scanning flow; provide empty defaults
    var prefixes: [String] { [] }
    var schemes: [String] { [] }
    var contains: [String] { [] }
    var suffex: [String] { [] }
    
    var placeholder: String {
        switch self {
        case .isbn: return "Enter your ISBN-10 or ISBN-13 number"
        case .ean8: return "Enter 7 or 8 digits"
        case .upce: return "Enter 7 or 8 digits"
        case .ean13: return "Enter 12 or 13 digits"
        case .upca: return "Enter 11 or 12 digits"
        case .code39: return "Encodes [0..9 A..Z -.$/+% Space]"
        case .code93: return "Encodes [0..9 A..Z -.$/+% Space]"
        case .code128: return "Encodes the full ASCII set [0..127]"
        case .itf: return "Enter plain text"
        case .pdf417: return "Enter plain text"
        }
    }
    
    var metadataObjectType: AVMetadataObject.ObjectType {
          switch self {
          case .isbn: return .ean13
          case .ean8: return .ean8
          case .upce: return .upce
          case .ean13: return .ean13
          case .upca: return .itf14
          case .code39: return .code39
          case .code93: return .code93
          case .code128: return .code128
          case .itf: return .interleaved2of5
          case .pdf417: return .pdf417
          }
      }
}
