//
//  CodeType.swift
//  Quick QR
//
//  Created by Haider Rathore on 30/08/2025.
//

import Foundation

// MARK: - QR Code Type Enum
enum CodeType: String, CaseIterable {
    case wifi = "wifi"
    case calendar = "calendar"
    case phone = "phone"
    case text = "text"
    case contact = "contact"
    case email = "email"
    case website = "website"
    case location = "location"
    case events = "events"
    case tiktok = "tiktok"
    case instagram = "instagram"
    case facebook = "facebook"
    case x = "x"
    case whatsapp = "whatsapp"
    case youtube = "youtube"
    case spotify = "spotify"
    case viber = "viber"
    case barcode = "barcode"
    
    var displayName: String {
        switch self {
        case .wifi: return "WiFi"
        case .calendar: return "Calendar"
        case .phone: return "Phone"
        case .text: return "Text"
        case .contact: return "Contact"
        case .email: return "Email"
        case .website: return "Website"
        case .location: return "Location"
        case .events: return "Events"
        case .tiktok: return "TikTok"
        case .instagram: return "Instagram"
        case .facebook: return "Facebook"
        case .x: return "X"
        case .whatsapp: return "WhatsApp"
        case .youtube: return "YouTube"
        case .spotify: return "Spotify"
        case .viber: return "Viber"
        case .barcode: return "Barcode"
        }
    }
    
    var buttonTitle: String {
        return "Generate \(displayName) QR"
    }
}
