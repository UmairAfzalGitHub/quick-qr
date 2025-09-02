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
    case developer // New section for developer options
    
    var title: String {
        switch self {
        case .premium:
            return "Premium"
        case .preferences:
            return "Preferences"
        case .other:
            return "Other"
        case .developer:
            return "Developer"
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
            return "Beep Sound"
        case .vibration:
            return "Vibration"
        case .language:
            return "Language"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .beep:
            return UIImage(systemName: "speaker.wave.2")
        case .vibration:
            return UIImage(systemName: "iphone.radiowaves.left.and.right")
        case .language:
            return UIImage(systemName: "globe")
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
            return "Share App"
        case .rateUs:
            return "Rate Us"
        case .feedback:
            return "Feedback"
        case .privacyPolicy:
            return "Privacy Policy"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .shareApp:
            return UIImage(systemName: "square.and.arrow.up")
        case .rateUs:
            return UIImage(systemName: "star")
        case .feedback:
            return UIImage(systemName: "envelope")
        case .privacyPolicy:
            return UIImage(systemName: "lock.shield")
        }
    }
}

enum DeveloperItem: Int, CaseIterable {
    case testRunner
    
    var title: String {
        switch self {
        case .testRunner:
            return "Test Runner"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .testRunner:
            return UIImage(systemName: "hammer")
        }
    }
}
