//
//  HistoryManager.swift
//  Quick QR
//
//  Created by Umair Afzal on 02/09/2025.
//

import Foundation

// MARK: - History Item Model
struct HistoryItem: Codable {
    enum ItemType: String, Codable {
        case qrCode
        case socialQRCode
        case barCode
    }
    
    let id: String
    let type: ItemType
    let subtype: String // Store the raw string of the enum case
    let content: String
    let title: String
    let timestamp: Date
    var isFavorite: Bool
    
    init(id: String = UUID().uuidString, type: ItemType, subtype: String, content: String, title: String, timestamp: Date = Date(), isFavorite: Bool = false) {
        self.id = id
        self.type = type
        self.subtype = subtype
        self.content = content
        self.title = title
        self.timestamp = timestamp
        self.isFavorite = isFavorite
    }
    
    // Convert to FavoriteItem for display
    func toFavoriteItem() -> FavoriteItem {
        let itemType: FavoriteItem.ItemType
        var displayContent = content
        
        switch type {
        case .qrCode:
            if let qrType = QRCodeType.allCases.first(where: { $0.title.lowercased() == subtype.lowercased() }) {
                itemType = .qrCode(qrType)
                
                // Special handling for WiFi QR codes that are stored as JSON
                if qrType == .wifi, let data = content.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    // Extract the actual data from JSON
                    if let ssid = json["ssid"] as? String {
                        let password = json["password"] as? String ?? ""
                        let isWep = json["isWep"] as? Bool ?? false
                        // Show the actual password in history
                        displayContent = "SSID: \(ssid), Password: \(password.isEmpty ? "<none>" : password), Security: \(isWep ? "WEP" : "WPA")"
                    }
                }
            } else {
                itemType = .qrCode(.text) // Default fallback
            }
        case .socialQRCode:
            if let socialType = SocialQRCodeType.allCases.first(where: { $0.title.lowercased() == subtype.lowercased() }) {
                itemType = .socialQRCode(socialType)
            } else {
                itemType = .socialQRCode(.facebook) // Default fallback
            }
        case .barCode:
            if let barType = BarCodeType.allCases.first(where: { $0.title.lowercased() == subtype.lowercased() }) {
                itemType = .barCode(barType)
            } else {
                itemType = .barCode(.code128) // Default fallback
            }
        }
        
        return FavoriteItem(type: itemType, title: title, url: displayContent, id: id, isFavorite: isFavorite)
    }
}

// MARK: - History Manager
class HistoryManager {
    static let shared = HistoryManager()
    
    private let userDefaults = UserDefaults.standard
    private let historyKey = "com.quickqr.history"
    
    private init() {}
    
    // MARK: - Save Methods
    
    func saveQRCodeHistory(type: QRCodeType, content: String) {
        let item = HistoryItem(
            type: .qrCode,
            subtype: type.title,
            content: content,
            title: type.title
        )
        saveHistoryItem(item)
    }
    
    func saveSocialQRCodeHistory(type: SocialQRCodeType, content: String) {
        let item = HistoryItem(
            type: .socialQRCode,
            subtype: type.title,
            content: content,
            title: type.title
        )
        saveHistoryItem(item)
    }
    
    func saveBarCodeHistory(type: BarCodeType, content: String) {
        let item = HistoryItem(
            type: .barCode,
            subtype: type.title,
            content: content,
            title: type.title
        )
        saveHistoryItem(item)
    }
    
    private func saveHistoryItem(_ item: HistoryItem) {
        var history = getAllHistory()
        history.insert(item, at: 0) // Add new items at the beginning
        
        // Limit history to 100 items to prevent excessive storage
        if history.count > 100 {
            history = Array(history.prefix(100))
        }
        
        if let encoded = try? JSONEncoder().encode(history) {
            userDefaults.set(encoded, forKey: historyKey)
            userDefaults.synchronize()
        }
    }
    
    // MARK: - Retrieve Methods
    
    func getAllHistory() -> [HistoryItem] {
        guard let data = userDefaults.data(forKey: historyKey),
              let history = try? JSONDecoder().decode([HistoryItem].self, from: data) else {
            return []
        }
        return history
    }
    
    func getCreatedHistory() -> [HistoryItem] {
        return getAllHistory()
    }
    
    func getScanHistory() -> [HistoryItem] {
        // For Phase 2 - currently returns empty array
        return []
    }
    
    // MARK: - Delete Methods
    
    func clearAllHistory() {
        userDefaults.removeObject(forKey: historyKey)
        userDefaults.synchronize()
    }
    
    func deleteHistoryItem(withId id: String) {
        var history = getAllHistory()
        history.removeAll { $0.id == id }
        
        if let encoded = try? JSONEncoder().encode(history) {
            userDefaults.set(encoded, forKey: historyKey)
            userDefaults.synchronize()
        }
    }
    
    // MARK: - Favorite Methods
    
    func toggleFavorite(forItemWithId id: String) -> Bool {
        var history = getAllHistory()
        
        // Find the item and toggle its favorite status
        if let index = history.firstIndex(where: { $0.id == id }) {
            history[index].isFavorite.toggle()
            
            // Save the updated history
            if let encoded = try? JSONEncoder().encode(history) {
                userDefaults.set(encoded, forKey: historyKey)
                userDefaults.synchronize()
            }
            
            // Return the new favorite status
            return history[index].isFavorite
        }
        
        return false
    }
    
    func getFavorites() -> [HistoryItem] {
        return getAllHistory().filter { $0.isFavorite }
    }
}
