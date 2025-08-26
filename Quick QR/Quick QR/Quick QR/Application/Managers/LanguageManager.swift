

import Foundation
import UIKit

class LanguageManager {
    
    static let shared = LanguageManager() // Singleton instance

    private static var bundleKey: UInt8 = 0
    private static let currentLanguageKey = "AppLanguage"
    
    // MARK: - Language Management
    
    static func currentLanguage() -> String {
        return UserDefaults.standard.string(forKey: currentLanguageKey) ?? "en"
    }
    
    static func storeCurrentLanguage(code: String) {
        UserDefaults.standard.set(code, forKey: currentLanguageKey)
        UserDefaults.standard.synchronize()
        updateBundleLanguage()
    }
    
    static func updateBundleLanguage() {
        guard let langCode = UserDefaults.standard.string(forKey: currentLanguageKey),
              let path = Bundle.main.path(forResource: langCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return
        }
        
        objc_setAssociatedObject(Bundle.main, &bundleKey, bundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    static func localizedString(forKey key: String) -> String {
        if let assocBundle = objc_getAssociatedObject(Bundle.main, &bundleKey) as? Bundle {
            return assocBundle.localizedString(forKey: key, value: nil, table: nil)
        }
        // Fallback: load bundle directly using current language code
        if let path = Bundle.main.path(forResource: currentLanguage(), ofType: "lproj"),
           let directBundle = Bundle(path: path) {
            return directBundle.localizedString(forKey: key, value: nil, table: nil)
        } else if let basePath = Bundle.main.path(forResource: "Base", ofType: "lproj"),
                  let baseBundle = Bundle(path: basePath) {
            return baseBundle.localizedString(forKey: key, value: nil, table: nil)
        }
        return Bundle.main.localizedString(forKey: key, value: nil, table: nil)
    }
    
    // MARK: - Semantic & Direction Support
    
    static func currentSemantic() -> UISemanticContentAttribute {
        return isLanguageRTL(languageCode: currentLanguage()) ? .forceRightToLeft : .forceLeftToRight
    }
    
    static func isLanguageRTL(languageCode: String) -> Bool {
        return ["ar", "ur", "fa", "he"].contains(languageCode) // Add Hebrew (he) if needed
    }
}


extension String {
    func localized() -> String {
        if let path = Bundle.main.path(forResource: LanguageManager.currentLanguage(), ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: self, value: nil as String?, table: nil)
        }
        else if let path = Bundle.main.path(forResource: "Base", ofType: "lproj"),
                let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: self, value: nil as String?, table: nil)
        }
        return self
    }
}

extension UILabel {
    func currentAllignment() {
        if LanguageManager.isLanguageRTL(languageCode: LanguageManager.currentLanguage()) {
            textAlignment = .right
        }else{
            textAlignment = .left
        }
    }
}

extension UITextField {
    func currentAllignment() {
        if LanguageManager.isLanguageRTL(languageCode: LanguageManager.currentLanguage()) {
            textAlignment = .right
        }
        else{
            textAlignment = .left
        }
    }
}

extension UIButton {
    func currentAllignment() {
        if LanguageManager.isLanguageRTL(languageCode: LanguageManager.currentLanguage()) {
            contentHorizontalAlignment = .right
        }
        else{
            contentHorizontalAlignment = .left
        }
    }
}
