//
//  QRCodeType.swift
//  Quick QR
//
//  Created by Haider Rathore on 28/08/2025.
//

import UIKit

enum QRCodeType: CaseIterable, CodeTypeProtocol {
    case wifi, phone, text, contact, email, website, location, events
    
    var title: String {
        switch self {
        case .wifi: return Strings.Label.wifi
        case .phone: return Strings.Label.phone
        case .text: return Strings.Label.text
        case .contact: return Strings.Label.contact
        case .email: return Strings.Label.email
        case .website: return Strings.Label.website
        case .location: return Strings.Label.location
        case .events: return Strings.Label.events
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
    
    // Matching helpers
    var prefixes: [String] {
        switch self {
        case .wifi: return ["wifi:"]
        case .phone: return ["tel:", "telprompt:"]
        case .text: return ["sms:", "smsto:"]
        case .contact: return ["mecard:"]
        case .email: return ["mailto:", "matmsg:"]
        case .location: return ["geo:", "maps.google.", "maps.apple."]
        case .website: return []
        case .events: return []
        }
    }

    var schemes: [String] {
        switch self {
        case .website: return ["http", "https"]
        case .text: return ["sms", "smsto"]
        case .location: return ["geo", "maps", "comgooglemaps"]
        default: return []
        }
    }

    var contains: [String] {
        switch self {
        case .contact: return ["begin:vcard"]
        case .location: return ["maps.google.", "maps.apple."]
        case .events: return ["begin:vevent", "begin:vcalendar"]
        default: return []
        }
    }

    var suffex: [String] {
        switch self {
        case .wifi: return ["wifi:"]
        case .phone: return ["tel:","telprompt:"]
        case .text: return ["sms:"]
        case .contact: return ["BEGIN:VCARD","mecard:"]
        case .email: return ["mailto","matmsg:"]
        case .website: return ["http","https"]
        case .location: return ["maps.google.com","maps.apple.com"]
        case .events: return ["BEGIN:VCALENDAR","BEGIN:VEVENT"]
        }
    }
}
