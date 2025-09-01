//
//  SocialQRCodeType.swift
//  Quick QR
//
//  Created by Haider Rathore on 28/08/2025.
//

import UIKit

enum SocialQRCodeType: CaseIterable, CodeTypeProtocol {
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
    
    // Matching helpers
    var prefixes: [String] { [] }
    var contains: [String] { [] }
    var schemes: [String] {
        switch self {
        case .viber: return ["viber"]
        case .whatsapp: return ["whatsapp"]
        default: return []
        }
    }
    
    var suffex: [String] {
        switch self {
        case .tiktok: return ["tiktok.com"]
        case .instagram: return ["instagram.com"]
        case .facebook: return ["facebook.com", "fb.com"]
        case .x: return ["x.com", "twitter.com", "twitter"]
        case .whatsapp: return ["whatsapp.com", "wa.me"]
        case .youtube: return ["youtube.com", "youtu.be"]
        case .spotify: return ["spotify.com"]
        case .viber: return ["vb.me"]
        }
    }
}
