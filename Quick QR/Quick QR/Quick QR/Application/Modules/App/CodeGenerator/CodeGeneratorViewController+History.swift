//
//  CodeGeneratorViewController+History.swift
//  Quick QR
//
//  Created by Umair Afzal on 02/09/2025.
//

import Foundation
import UIKit

// MARK: - History Content Helpers
extension CodeGeneratorViewController {
    
    func getQRCodeContent(for type: QRCodeType) -> String {
        switch type {
        case .wifi:
            guard let wifiView = wifiView,
                  let ssid = wifiView.getSSID(),
                  let password = wifiView.getPassword(),
                  !ssid.isEmpty else {
                return ""
            }
            
            // Store the actual data in JSON format for proper parsing when loaded from history
            // This allows us to keep the actual password while displaying a masked version in UI
            let wifiData: [String: Any] = [
                "ssid": ssid,
                "password": password,
                "isWep": wifiView.isWEP(),
                "displayText": "SSID: \(ssid), Password: \(password.isEmpty ? "<none>" : password), Security: \(wifiView.isWEP() ? "WEP" : "WPA")"
            ]
            
            if let jsonData = try? JSONSerialization.data(withJSONObject: wifiData),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
            
            // Fallback to the old format if JSON serialization fails
            return "WIFI:S:\(ssid);T:\(wifiView.isWEP() ? "WEP" : "WPA");P:\(password);;"
            
        case .phone:
            guard let phoneView = phoneView,
                  let phoneNumber = phoneView.getPhoneNumber(),
                  !phoneNumber.isEmpty else {
                return ""
            }
            return phoneNumber
            
        case .text:
            guard let textView = textView,
                  let text = textView.getText(),
                  !text.isEmpty else {
                return ""
            }
            
            // Check if we have a phone number for SMS
            if let phoneNumber = textView.phoneNumberText, !phoneNumber.isEmpty {
                return "SMS to: \(phoneNumber), Message: \(text)"
            }
            
            return text
            
        case .contact:
            guard let contactsView = contactsView else { return "" }
            
            var contactInfo = ""
            if let name = contactsView.getName(), !name.isEmpty {
                contactInfo += "Name: \(name)"
            }
            if let phone = contactsView.getPhone(), !phone.isEmpty {
                contactInfo += contactInfo.isEmpty ? "" : ", "
                contactInfo += "Phone: \(phone)"
            }
            if let email = contactsView.getEmail(), !email.isEmpty {
                contactInfo += contactInfo.isEmpty ? "" : ", "
                contactInfo += "Email: \(email)"
            }
            
            return contactInfo
            
        case .email:
            guard let emailView = emailView else { return "" }
            
            var emailInfo = ""
            if let email = emailView.getEmail(), !email.isEmpty {
                emailInfo += "To: \(email)"
            }
            if let subject = emailView.getSubject(), !subject.isEmpty {
                emailInfo += emailInfo.isEmpty ? "" : ", "
                emailInfo += "Subject: \(subject)"
            }
            
            return emailInfo
            
        case .website:
            guard let websiteView = websiteView,
                  let url = websiteView.getURL(),
                  !url.isEmpty else {
                return ""
            }
            return url
            
        case .location:
            guard let locationView = locationView else { return "" }
            
            var locationInfo = ""
            if let latitude = locationView.getLatitude(), !latitude.isEmpty,
               let longitude = locationView.getLongitude(), !longitude.isEmpty {
                locationInfo = "Lat: \(latitude), Long: \(longitude)"
            }
            
            return locationInfo
            
        case .events:
            guard let calendarView = calendarView else { return "" }
            
            var eventInfo = ""
            if let title = calendarView.getTitle(), !title.isEmpty {
                eventInfo += "Title: \(title)"
            }
            if let location = calendarView.getLocation(), !location.isEmpty {
                eventInfo += eventInfo.isEmpty ? "" : ", "
                eventInfo += "Location: \(location)"
            }
            
            return eventInfo
        }
    }
    
    func getSocialQRCodeContent(for type: SocialQRCodeType) -> String {
        var username = ""
        
        switch type {
        case .facebook:
            guard let facebookView = facebookView,
                  let user = facebookView.getUsername(),
                  !user.isEmpty else {
                return ""
            }
            username = user
            
        case .x:
            guard let xView = xView,
                  let user = xView.getUsername(),
                  !user.isEmpty else {
                return ""
            }
            username = user
            
        case .instagram:
            guard let instagramView = instagramView,
                  let user = instagramView.getUsername(),
                  !user.isEmpty else {
                return ""
            }
            username = user
            
        case .tiktok:
            guard let tiktokView = tiktokView,
                  let user = tiktokView.getUsername(),
                  !user.isEmpty else {
                return ""
            }
            username = user
            
        case .youtube:
            guard let youtubeView = youtubeView,
                  let user = youtubeView.getUsername(),
                  !user.isEmpty else {
                return ""
            }
            username = user
            
        case .whatsapp:
            guard let whatsappView = whatsappView,
                  let phone = whatsappView.getPhoneNumber(),
                  !phone.isEmpty else {
                return ""
            }
            username = phone
                        
        case .spotify:
            guard let spotifyView = spotifyView else { return "" }
            
            // Try to get custom URL first
            if let url = spotifyView.getUrl(), !url.isEmpty {
                return url
            }
            
            // Fall back to username-based URL if no custom URL is provided
            guard let user = spotifyView.getUsername(), !user.isEmpty else {
                return ""
            }
            username = user
            
        case .viber:
            guard let viberView = viberView,
                  let user = viberView.getPhoneNumber(),
                  !user.isEmpty else {
                return ""
            }
            username = user
        }
        
        return "\(type.title): \(username)"
    }
}
