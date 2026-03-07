//
//  HistoryManager.swift
//  Quick QR
//
//  Created by Umair Afzal on 02/09/2025.
//

import Foundation
import AVFoundation

// MARK: - History Item Model
// MARK: - History Item Model
struct BatchScanItem {
    let value: String
    let type: AVMetadataObject.ObjectType
    let scanResult: ScanDataParser.ScanResult
    let timestamp: Date
}

struct HistoryItem: Codable {
    enum ItemType: String, Codable {
        case qrCode
        case socialQRCode
        case barCode
        case batchScan
    }
    
    let id: String
    let type: ItemType
    let subtype: String // Store the raw string of the enum case
    let content: String
    let title: String
    let timestamp: Date
    var isFavorite: Bool
    let imageFileName: String?
    
    init(id: String = UUID().uuidString, type: ItemType, subtype: String, content: String, title: String, timestamp: Date = Date(), isFavorite: Bool = false, imageFileName: String? = nil) {
        self.id = id
        self.type = type
        self.subtype = subtype
        self.content = content
        self.title = title
        self.timestamp = timestamp
        self.isFavorite = isFavorite
        self.imageFileName = imageFileName
    }
    
    // Convert to FavoriteItem for display
    func toFavoriteItem(origin: FavoriteItem.Origin) -> FavoriteItem {
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
        case .batchScan:
            itemType = .batchScan
            // Show item count summary instead of raw JSON content
            if let data = content.data(using: .utf8),
               let dicts = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                displayContent = "\(dicts.count) items scanned"
            } else {
                displayContent = "Batch scan"
            }
        }
        
        return FavoriteItem(type: itemType, title: title, url: displayContent, id: id, isFavorite: isFavorite, origin: origin)
    }
}

// MARK: - History Manager
class HistoryManager {
    static let shared = HistoryManager()
    
    private let userDefaults = UserDefaults.standard
    private let historyKey = "com.quickqr.history"
    private let scanHistoryKey = "com.quickqr.scanhistory"
    private let favoritesKey = "com.quickqr.favorites"
    
    private init() {}
    
    // MARK: - Save Methods
    
    // Created codes
    func saveQRCodeHistory(type: QRCodeType, content: String) {
        let item = HistoryItem(
            type: .qrCode,
            subtype: type.title,
            content: content,
            title: type.title
        )
        saveHistoryItem(item, forScan: false)
    }
    
    func saveSocialQRCodeHistory(type: SocialQRCodeType, content: String) {
        let item = HistoryItem(
            type: .socialQRCode,
            subtype: type.title,
            content: content,
            title: type.title
        )
        saveHistoryItem(item, forScan: false)
    }
    
    func saveBarCodeHistory(type: BarCodeType, content: String) {
        let item = HistoryItem(
            type: .barCode,
            subtype: type.title,
            content: content,
            title: type.title
        )
        saveHistoryItem(item, forScan: false)
    }
    
    // Scanned codes
    func saveScannedQRCodeHistory(type: QRCodeType, content: String, imageFileName: String? = nil) {
        let item = HistoryItem(
            type: .qrCode,
            subtype: type.title,
            content: content,
            title: type.title,
            imageFileName: imageFileName
        )
        saveHistoryItem(item, forScan: true)
    }
    
    func saveScannedSocialQRCodeHistory(type: SocialQRCodeType, content: String, imageFileName: String? = nil) {
        let item = HistoryItem(
            type: .socialQRCode,
            subtype: type.title,
            content: content,
            title: type.title,
            imageFileName: imageFileName
        )
        saveHistoryItem(item, forScan: true)
    }
    
    func saveScannedBarCodeHistory(type: BarCodeType, content: String, imageFileName: String? = nil) {
        let item = HistoryItem(
            type: .barCode,
            subtype: type.title,
            content: content,
            title: type.title,
            imageFileName: imageFileName
        )
        saveHistoryItem(item, forScan: true)
    }

    /// Saves an entire batch scan session as a single history item.
    /// The individual items are serialized to JSON in the `content` field.
    func saveBatchScanHistory(_ batchItems: [BatchScanItem]) {
        guard !batchItems.isEmpty else { return }

        // Encode each item as a simple dictionary
        let itemDicts: [[String: String]] = batchItems.map { item in
            [
                "value": item.value,
                "type": item.type.rawValue,
                "title": item.scanResult.title ?? "Unknown"
            ]
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: itemDicts),
              let jsonString = String(data: jsonData, encoding: .utf8) else { return }

        let item = HistoryItem(
            type: .batchScan,
            subtype: "batch",
            content: jsonString,
            title: "Batch Scan (\(batchItems.count) items)"
        )
        saveHistoryItem(item, forScan: true)
    }

    /// Decodes batch scan items from a history item's JSON content.
    func decodeBatchItems(from historyItem: HistoryItem) -> [BatchScanItem] {
        guard historyItem.type == .batchScan,
              let data = historyItem.content.data(using: .utf8),
              let dicts = try? JSONSerialization.jsonObject(with: data) as? [[String: String]] else {
            return []
        }

        return dicts.compactMap { dict in
            guard let value = dict["value"],
                  let typeRaw = dict["type"] else { return nil }
            let metaType = AVMetadataObject.ObjectType(rawValue: typeRaw)
            let scanResult = ScanDataParser.parse(data: value, symbology: metaType)
            return BatchScanItem(value: value, type: metaType, scanResult: scanResult, timestamp: historyItem.timestamp)
        }
    }
    
    private func saveHistoryItem(_ item: HistoryItem, forScan: Bool) {
        let key = forScan ? scanHistoryKey : historyKey
        var history = getHistory(forScan: forScan)
        history.insert(item, at: 0)
        if history.count > 100 {
            history = Array(history.prefix(100))
        }
        if let encoded = try? JSONEncoder().encode(history) {
            userDefaults.set(encoded, forKey: key)
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
    
    private func getHistory(forScan: Bool) -> [HistoryItem] {
        let key = forScan ? scanHistoryKey : historyKey
        guard let data = userDefaults.data(forKey: key),
              let history = try? JSONDecoder().decode([HistoryItem].self, from: data) else {
            return []
        }
        return history
    }
    
    func getScanHistory() -> [HistoryItem] {
        return getHistory(forScan: true)
    }
    
    // MARK: - Delete Methods
    
    func clearAllHistory() {
        userDefaults.removeObject(forKey: historyKey)
        userDefaults.removeObject(forKey: scanHistoryKey)
        userDefaults.synchronize()
    }
    
    func deleteHistoryItem(withId id: String, fromScan: Bool? = nil) {
        // Check if this item is in favorites
        let favorites = getFavoriteItems()
        let isFavorited = favorites.contains { $0.id == id }
        
        // If fromScan is nil, try both
        if let fromScan = fromScan {
            var history = getHistory(forScan: fromScan)
            history.removeAll { $0.id == id }
            let key = fromScan ? scanHistoryKey : historyKey
            if let encoded = try? JSONEncoder().encode(history) {
                userDefaults.set(encoded, forKey: key)
                userDefaults.synchronize()
            }
        } else {
            // Try deleting from both created and scan history
            deleteHistoryItem(withId: id, fromScan: false)
            deleteHistoryItem(withId: id, fromScan: true)
        }
        
        // Important: We don't remove from favorites when deleting from history
        // This allows favorites to persist even when removed from history
    }
    
    // MARK: - Favorite Methods
    
    // Get favorites directly from favorites storage
    private func getFavoriteItems() -> [HistoryItem] {
        guard let data = userDefaults.data(forKey: favoritesKey),
              let favorites = try? JSONDecoder().decode([HistoryItem].self, from: data) else {
            return []
        }
        return favorites
    }
    
    // Save favorites to separate storage
    private func saveFavoriteItems(_ items: [HistoryItem]) {
        if let encoded = try? JSONEncoder().encode(items) {
            userDefaults.set(encoded, forKey: favoritesKey)
            userDefaults.synchronize()
        }
    }
    
    // Add an item to favorites
    private func addToFavorites(_ item: HistoryItem) {
        var favorites = getFavoriteItems()
        
        // Check if this item is already in favorites
        if !favorites.contains(where: { $0.id == item.id }) {
            var favoriteItem = item
            favoriteItem.isFavorite = true
            favorites.append(favoriteItem)
            saveFavoriteItems(favorites)
        }
    }
    
    // Remove an item from favorites
    private func removeFromFavorites(withId id: String) {
        var favorites = getFavoriteItems()
        favorites.removeAll { $0.id == id }
        saveFavoriteItems(favorites)
    }
    
    // Public method to delete an item from favorites only
    func deleteFavoriteItem(withId id: String) {
        removeFromFavorites(withId: id)
        
        // Also update the flag in history items if they still exist
        updateFavoriteFlag(id: id, isFavorite: false, forScan: false)
        updateFavoriteFlag(id: id, isFavorite: false, forScan: true)
    }
    
    func toggleFavorite(forItemWithId id: String) -> Bool {
        // First check if it's in favorites
        let favorites = getFavoriteItems()
        if let index = favorites.firstIndex(where: { $0.id == id }) {
            // It's in favorites, so remove it
            removeFromFavorites(withId: id)
            
            // Also update the flag in history items
            updateFavoriteFlag(id: id, isFavorite: false, forScan: false)
            updateFavoriteFlag(id: id, isFavorite: false, forScan: true)
            
            return false
        }
        
        // Not in favorites, so try to add it from history
        var history = getHistory(forScan: false)
        if let index = history.firstIndex(where: { $0.id == id }) {
            // Add to favorites
            addToFavorites(history[index])
            
            // Update flag in history
            updateFavoriteFlag(id: id, isFavorite: true, forScan: false)
            
            return true
        }
        
        // Try scan history
        var scanHistory = getHistory(forScan: true)
        if let index = scanHistory.firstIndex(where: { $0.id == id }) {
            // Add to favorites
            addToFavorites(scanHistory[index])
            
            // Update flag in history
            updateFavoriteFlag(id: id, isFavorite: true, forScan: true)
            
            return true
        }
        
        return false
    }
    
    // Helper method to update the favorite flag in history items
    private func updateFavoriteFlag(id: String, isFavorite: Bool, forScan: Bool) {
        let key = forScan ? scanHistoryKey : historyKey
        var history = getHistory(forScan: forScan)
        
        if let index = history.firstIndex(where: { $0.id == id }) {
            history[index].isFavorite = isFavorite
            if let encoded = try? JSONEncoder().encode(history) {
                userDefaults.set(encoded, forKey: key)
                userDefaults.synchronize()
            }
        }
    }
    
    func getFavorites() -> [FavoriteItem] {
        // Get favorites directly from favorites storage
        let favorites = getFavoriteItems()
        
        // Map to FavoriteItem and determine origin
        return favorites.map { item -> FavoriteItem in
            // Try to determine if this was from scan or created history
            let createdHistory = getHistory(forScan: false)
            let origin: FavoriteItem.Origin = createdHistory.contains(where: { $0.id == item.id }) ? .created : .scanned
            return item.toFavoriteItem(origin: origin)
        }
    }
    
    /// Checks if content already exists in favorites
    /// - Parameter content: The content to check
    /// - Returns: (Bool, String?) - Bool indicates if it's a favorite, String is the item ID if found
    func isContentFavorited(_ content: String) -> (isFavorite: Bool, itemId: String?) {
        // First check in favorites storage
        let favorites = getFavoriteItems()
        if let item = favorites.first(where: { $0.content == content }) {
            return (true, item.id)
        }
        
        // If not in favorites, check if content exists in history but is not favorited
        let createdHistory = getHistory(forScan: false)
        if let item = createdHistory.first(where: { $0.content == content }) {
            return (false, item.id)
        }
        
        let scanHistory = getHistory(forScan: true)
        if let item = scanHistory.first(where: { $0.content == content }) {
            return (false, item.id)
        }
        
        return (false, nil)
    }
}
