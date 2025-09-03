//
//  FeedbackManager.swift
//  Quick QR
//
//  Created by Umair Afzal on 03/09/2025.
//

import Foundation
import AVFoundation
import UIKit

class FeedbackManager {
    
    // MARK: - Singleton
    static let shared = FeedbackManager()
    
    // MARK: - Properties
    private var audioPlayer: AVAudioPlayer?
    private let hapticFeedback = UINotificationFeedbackGenerator()
    
    // MARK: - UserDefaults Keys
    private enum UserDefaultsKeys {
        static let isSoundEnabled = "isSoundEnabled"
        static let isVibrationEnabled = "isVibrationEnabled"
    }
    
    // MARK: - Public Properties
    var isSoundEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaultsKeys.isSoundEnabled)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.isSoundEnabled)
        }
    }
    
    var isVibrationEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaultsKeys.isVibrationEnabled)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.isVibrationEnabled)
        }
    }
    
    // MARK: - Initialization
    private init() {
        // Set default values if not set
        if !UserDefaults.standard.contains(key: UserDefaultsKeys.isSoundEnabled) {
            isSoundEnabled = true // Default to enabled
        }
        
        if !UserDefaults.standard.contains(key: UserDefaultsKeys.isVibrationEnabled) {
            isVibrationEnabled = true // Default to enabled
        }
        
        // Prepare audio player
        prepareAudioPlayer()
        
        // Prepare haptic feedback
        hapticFeedback.prepare()
    }
    
    // MARK: - Public Methods
    
    /// Play beep sound when a code is scanned
    func playBeepSound() {
        guard isSoundEnabled else { return }
        
        // Play the sound
        audioPlayer?.play()
    }
    
    /// Trigger haptic feedback when a code is scanned
    func triggerHapticFeedback() {
        guard isVibrationEnabled else { return }
        
        // Trigger haptic feedback
        hapticFeedback.notificationOccurred(.success)
    }
    
    /// Provide feedback (sound and/or haptic) when a code is scanned
    func provideScanFeedback() {
        playBeepSound()
        triggerHapticFeedback()
    }
    
    // MARK: - Private Methods
    
    /// Prepare the audio player with the beep sound
    private func prepareAudioPlayer() {
        guard let soundURL = Bundle.main.url(forResource: "beep", withExtension: "mp3") else {
            print("Error: Beep sound file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error initializing audio player: \(error.localizedDescription)")
        }
    }
}

// MARK: - UserDefaults Extension
extension UserDefaults {
    func contains(key: String) -> Bool {
        return object(forKey: key) != nil
    }
}
