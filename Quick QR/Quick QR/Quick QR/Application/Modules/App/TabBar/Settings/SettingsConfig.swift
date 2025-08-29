//
//  SettingsConfig.swift
//  Quick QR
//
//  Created by Umair Afzal on 29/08/2025.
//

import Foundation
import UIKit

// MARK: - Settings Models
enum SettingsSection: Int, CaseIterable {
    case premium
    case preferences
    case other
    
    var title: String? {
        switch self {
        case .premium: return nil
        case .preferences: return nil
        case .other: return "Other"
        }
    }
}

enum PreferenceItem: Int, CaseIterable {
    case beep
    case vibration
    case language
    
    var title: String {
        switch self {
        case .beep: return "Beep"
        case .vibration: return "Vibration"
        case .language: return "Language"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .beep: return UIImage(named: "beep-settings")
        case .vibration: return UIImage(named: "vibrate-settings")
        case .language: return UIImage(named: "lang-settings")
        }
    }
    
    var hasSwitch: Bool {
        switch self {
        case .beep, .vibration: return true
        case .language: return false
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
        case .shareApp: return "Share app"
        case .rateUs: return "Rate for us"
        case .feedback: return "Feedback"
        case .privacyPolicy: return "Privacy policy"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .shareApp: return UIImage(named: "share-settings")
        case .rateUs: return UIImage(named: "rate-settings")
        case .feedback: return UIImage(named: "feedback-settings")
        case .privacyPolicy: return UIImage(named: "privacy-settings")
        }
    }
}
