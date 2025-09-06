//
//  SettingsViewController+Enums.swift
//  Quick QR
//
//  Created by Umair Afzal on 02/09/2025.
//

import UIKit

// MARK: - Enums

enum SettingsSection: Int, CaseIterable {
    case premium
    case preferences
    case other
    
    var title: String {
        switch self {
        case .premium:
            return Strings.Label.premium
        case .preferences:
            return Strings.Label.preferences
        case .other:
            return Strings.Label.other
        }
    }
}

enum PreferenceItem: Int, CaseIterable {
    case beep
    case vibration
    case language
    
    var title: String {
        switch self {
        case .beep:
            return Strings.Label.beepSound
        case .vibration:
            return Strings.Label.vibration
        case .language:
            return Strings.Label.lanugage
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .beep:
            return UIImage(named: "beep-settings")
        case .vibration:
            return UIImage(named: "vibrate-settings")
        case .language:
            return UIImage(named: "lang-settings")
        }
    }
    
    var hasSwitch: Bool {
        switch self {
        case .beep, .vibration:
            return true
        case .language:
            return false
        }
    }
}

enum OtherItem: Int, CaseIterable {
    case shareApp
    case rateUs
    case feedback
    case privacyPolicy
    
    var title: String {
        switch self {
        case .shareApp:
            return Strings.Label.shareApp
        case .rateUs:
            return Strings.Label.rateUs
        case .feedback:
            return Strings.Label.feedback
        case .privacyPolicy:
            return Strings.Label.privacyPolicy
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .shareApp:
            return UIImage(named: "share-settings")
        case .rateUs:
            return UIImage(named: "rate-settings")
        case .feedback:
            return UIImage(named: "feedback-settings")
        case .privacyPolicy:
            return UIImage(named: "privacy-settings")
        }
    }
}
