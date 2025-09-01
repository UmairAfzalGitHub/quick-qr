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
    
    var suffex: [String]? {
        switch self {
        case .wifi: return ["wifi:"]
        case .phone: return ["tel:","telprompt:"]
        case .text: return ["sms:"]
        case .contact: return ["BEGIN:VCARD","mecard:"]
        case .email: return ["mailto","matmsg:"]
        case .website: return ["http","https"]
        case .location: return ["maps.google.","maps.apple.","geo:"]
        case .events: return ["BEGIN:VCALENDAR","BEGIN:VEVENT"]
        }
    }
}
