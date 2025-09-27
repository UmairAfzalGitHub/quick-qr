//
//  SceneDelegate.swift
//  ProductBoilerPlate
//
//  Created by Umair Afzal on 02/08/2025.
//

import UIKit
import FirebaseCore
import IQKeyboardManagerSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.overrideUserInterfaceStyle = .light
        window?.rootViewController = SplashViewController()
        window?.makeKeyAndVisible()
        
        isRunningGreaterThanAppStoreVersion { isGreater in
            DispatchQueue.main.async {
                if isGreater {
                    print("🚨 Running a version greater than App Store (review mode)")
                    // Hide features or enable review mode
                    RemoteConfigManager.shared.splashInterstitialEnabled = false
                    RemoteConfigManager.shared.maxInterstitalAdCounter = 7
                    RemoteConfigManager.shared.adLoaderCounter = 6
                } else {
                    print("✅ Running App Store or lower version")
                    // Show all features
                }
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        let launchCounter = UserDefaults.standard.value(forKey: "appLaunchCounter") as? Int ?? 0
        
        if launchCounter > 2 {
            AdManager.shared.showAppOpenAd()
        } else {
            // Mark the app as launched for future reference
            UserDefaults.standard.set(launchCounter+1, forKey: "appLaunchCounter")
            UserDefaults.standard.synchronize()
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    func isRunningGreaterThanAppStoreVersion(completion: @escaping (Bool) -> Void) {
        guard let bundleID = Bundle.main.bundleIdentifier else {
            completion(false)
            return
        }
        let urlString = "https://itunes.apple.com/lookup?bundleId=\(bundleID)"
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            do {
                if let result = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let results = result["results"] as? [[String: Any]],
                   let appStoreVersion = results.first?["version"] as? String,
                   let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                    
                    let isGreater = self.isCurrentVersionGreater(currentVersion: currentVersion, appStoreVersion: appStoreVersion)
                    completion(isGreater)
                } else {
                    completion(false)
                }
            } catch {
                completion(false)
            }
        }.resume()
    }

    func isCurrentVersionGreater(currentVersion: String, appStoreVersion: String) -> Bool {
        let currentParts = currentVersion.split(separator: ".").compactMap { Int($0) }
        let storeParts = appStoreVersion.split(separator: ".").compactMap { Int($0) }
        let maxCount = max(currentParts.count, storeParts.count)
        
        for i in 0..<maxCount {
            let current = i < currentParts.count ? currentParts[i] : 0
            let store = i < storeParts.count ? storeParts[i] : 0
            
            if current > store {
                return true   // ✅ current is newer
            } else if current < store {
                return false  // 🚫 current is older
            }
        }
        return false // equal
    }
}

extension UIApplication {
    var activeWindow: UIWindow? {
        let sceneDelegate = (connectedScenes.first as? UIWindowScene)?.delegate as? SceneDelegate
        return sceneDelegate?.window
    }
}
