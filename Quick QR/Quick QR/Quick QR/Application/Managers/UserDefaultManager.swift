

import Foundation

class UserDefaultManager: NSObject {
    static let shared = UserDefaultManager()
    
    private override init() {
        super.init()
    }
    
    // MARK: - UserDefaults Keys and Values
    enum UserDefaultsKey {
        // Authentication & Onboarding
        case onBoarding(Bool)
        case termsAccepted(Bool)
        case gdprConsent(Bool)
        
        // Subscription & Premium
        case isSubscribed(Bool)
        case isPremiumMember(Bool)
        case subscriptionPurchaseDate(Date)
        
        // Saved Media
        case savedImagesIdentifiers([String: String])
        case savedVideosIdentifiers([String: String])
        
        // App Settings
        case appLanguage(String)
        case appLanguageTitle(String)
        
        // Tooltips
        case homeTooltipShown(Bool)
        case classificationTooltipShown(Bool)
        
        // Screen Visits
        case isFirstCodeGeneratorVisit(Bool)

        var key: String {
            switch self {
            case .onBoarding: return "isOnboardingComplete"
            case .termsAccepted: return "isTermAccecpted"
            case .gdprConsent: return "GDPRConsentStatus"
            case .isSubscribed: return "isSubscribed"
            case .isPremiumMember: return "isPremiumMember"
            case .subscriptionPurchaseDate: return "subscriptionPurchaseDate"
            case .savedImagesIdentifiers: return "SavedImagesIdentifiers"
            case .savedVideosIdentifiers: return "SavedVideosIdentifiers"
            case .appLanguage: return "appLanguage"
            case .appLanguageTitle: return "appLanguageTitle"
            case .homeTooltipShown: return "homeTooltipShown"
            case .classificationTooltipShown: return "classificationTooltipShown"
            case .isFirstCodeGeneratorVisit: return "isFirstCodeGeneratorVisit"
            }
        }
        
        var value: Any? {
            switch self {
            case .onBoarding(let value),
                    .termsAccepted(let value),
                    .gdprConsent(let value),
                    .isSubscribed(let value),
                    .isPremiumMember(let value),
                    .homeTooltipShown(let value),
                    .classificationTooltipShown(let value),
                    .isFirstCodeGeneratorVisit(let value):
                return value
            case .subscriptionPurchaseDate(let value):
                return value
            case .appLanguage(let value),
                    .appLanguageTitle(let value):
                return value
            case .savedImagesIdentifiers(let value),
                    .savedVideosIdentifiers(let value):
                return value
            }
        }
    }
    
    // MARK: - Set Value
    func setValue(_ key: UserDefaultsKey) {
        UserDefaults.standard.set(key.value, forKey: key.key)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Get Value
    func getValue(_ key: UserDefaultsKey) -> Any? {
        switch key {
        case .onBoarding:
            return UserDefaults.standard.bool(forKey: UserDefaultsKey.onBoarding(false).key)
        case .termsAccepted:
            return UserDefaults.standard.bool(forKey: UserDefaultsKey.termsAccepted(false).key)
        case .gdprConsent:
            return UserDefaults.standard.bool(forKey: UserDefaultsKey.gdprConsent(false).key)
        case .isSubscribed:
            return UserDefaults.standard.bool(forKey: UserDefaultsKey.isSubscribed(false).key)
        case .isPremiumMember:
            return UserDefaults.standard.bool(forKey: UserDefaultsKey.isPremiumMember(false).key)
        case .homeTooltipShown:
            return UserDefaults.standard.bool(forKey: UserDefaultsKey.homeTooltipShown(false).key)
        case .classificationTooltipShown:
            return UserDefaults.standard.bool(forKey: UserDefaultsKey.classificationTooltipShown(false).key)
        case .isFirstCodeGeneratorVisit:
            return UserDefaults.standard.bool(forKey: UserDefaultsKey.isFirstCodeGeneratorVisit(true).key)
        case .subscriptionPurchaseDate:
            return UserDefaults.standard.object(forKey: UserDefaultsKey.subscriptionPurchaseDate(Date()).key) as? Date
        case .savedImagesIdentifiers:
            return UserDefaults.standard.dictionary(forKey: UserDefaultsKey.savedImagesIdentifiers([:]).key) as? [String: String] ?? [:]
        case .savedVideosIdentifiers:
            return UserDefaults.standard.dictionary(forKey: UserDefaultsKey.savedVideosIdentifiers([:]).key) as? [String: String] ?? [:]
        case .appLanguage:
            return UserDefaults.standard.string(forKey: UserDefaultsKey.appLanguage("").key)
        case .appLanguageTitle:
            return UserDefaults.standard.string(forKey: UserDefaultsKey.appLanguageTitle("").key)
        }
    }
    
    // MARK: - Remove Value
    func removeValue(_ key: UserDefaultsKey) {
        UserDefaults.standard.removeObject(forKey: key.key)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Clear Methods
    func clearAllUserDefaults() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
    
    // MARK: - Tooltip Methods
    
    func isHomeTooltipShown() -> Bool {
        return getValue(.homeTooltipShown(false)) as? Bool ?? false
    }
    
    func setHomeTooltipShown(_ shown: Bool) {
        setValue(.homeTooltipShown(shown))
    }
    
    func isClassificationTooltipShown() -> Bool {
        return getValue(.classificationTooltipShown(false)) as? Bool ?? false
    }
    
    func setClassificationTooltipShown(_ shown: Bool) {
        setValue(.classificationTooltipShown(shown))
    }

    // MARK: - Code Generator Visit Methods

    func isFirstCodeGeneratorVisit() -> Bool {
        // Returns true if it's the first visit (default is true)
        return getValue(.isFirstCodeGeneratorVisit(true)) as? Bool ?? true
    }

    func setCodeGeneratorVisited() {
        // Set to false after first visit
        setValue(.isFirstCodeGeneratorVisit(false))
    }
}
