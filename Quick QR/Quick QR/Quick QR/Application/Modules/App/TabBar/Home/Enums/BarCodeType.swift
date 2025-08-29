//
//  BarCodeType.swift
//  Quick QR
//
//  Created by Haider Rathore on 28/08/2025.
//

import UIKit

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
