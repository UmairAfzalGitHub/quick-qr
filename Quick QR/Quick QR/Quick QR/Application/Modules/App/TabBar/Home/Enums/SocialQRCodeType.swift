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
        case .tiktok: return Strings.Label.tikTok
        case .instagram: return Strings.Label.instagram
        case .facebook: return Strings.Label.facebook
        case .x: return Strings.Label.x
        case .whatsapp: return Strings.Label.whatsApp
        case .youtube: return Strings.Label.youtube
        case .spotify: return Strings.Label.spotify
        case .viber: return Strings.Label.viber
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
