//
//  SettingsViewController.swift
//  Quick QR
//
//  Created by Umair Afzal on 29/08/2025.
//

import UIKit
import IOS_Helpers

// Import the enums for settings
@_exported import Foundation
// Enums are defined in SettingsViewController+Enums.swift
// No explicit import needed as they're in the same module

class SettingsViewController: UIViewController,
                              SettingsCellDelegate,
                              UITableViewDelegate,
                              UITableViewDataSource{
    
    // MARK: - Properties
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let premiumBannerView = PremiumBannerView()
    
    // State properties
    private var isBeepEnabled: Bool = FeedbackManager.shared.isSoundEnabled
    private var isVibrationEnabled: Bool = FeedbackManager.shared.isVibrationEnabled
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Settings"
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .singleLine
        tableView.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.identifier)
        
        // Set up premium banner as header view for first section
        premiumBannerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 120)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - SettingsCellDelegate
    func settingsCell(_ cell: SettingsCell, didChangeSwitchValue isOn: Bool, forTag tag: Int) {
        if let item = PreferenceItem(rawValue: tag) {
            switch item {
            case .beep:
                isBeepEnabled = isOn
                // Save preference to FeedbackManager
                FeedbackManager.shared.isSoundEnabled = isOn
            case .vibration:
                isVibrationEnabled = isOn
                // Save preference to FeedbackManager
                FeedbackManager.shared.isVibrationEnabled = isOn
            default:
                break
            }
        }
    }
    
    // MARK: - UITableViewDelegate & UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Show developer section only in debug mode
        #if DEBUG
            return SettingsSection.allCases.count
        #else
            return SettingsSection.allCases.count - 1 // Hide developer section in release builds
        #endif
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = SettingsSection(rawValue: section)!
        switch section {
        case .premium:
            return 0 // Premium banner is in the header
        case .preferences:
            return PreferenceItem.allCases.count
        case .other:
            return OtherItem.allCases.count
        case .developer:
            return DeveloperItem.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = SettingsSection(rawValue: indexPath.section)!
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.identifier, for: indexPath) as! SettingsCell
        cell.delegate = self
        
        switch section {
        case .premium:
            return UITableViewCell() // Should not reach here
            
        case .preferences:
            let item = PreferenceItem(rawValue: indexPath.row)!
            
            if item.hasSwitch {
                let isOn = item == .beep ? isBeepEnabled : isVibrationEnabled
                cell.configure(with: item.title, icon: item.icon, accessoryType: .toggle(isOn: isOn), tag: indexPath.row)
            } else {
                cell.configure(with: item.title, icon: item.icon, accessoryType: .navigation)
            }
            
        case .other:
            let item = OtherItem(rawValue: indexPath.row)!
            cell.configure(with: item.title, icon: item.icon, accessoryType: .navigation)
            
        case .developer:
            let item = DeveloperItem(rawValue: indexPath.row)!
            cell.configure(with: item.title, icon: item.icon, accessoryType: .navigation)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Not using this method anymore as we're using viewForHeaderInSection for custom styling
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = SettingsSection(rawValue: section)!
        
        if section == .premium {
            return premiumBannerView
        } else if section == .other || section == .developer {
            // Create a custom header view with bold black text
            let headerView = UIView()
            headerView.backgroundColor = .systemBackground
            
            let titleLabel = UILabel()
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.text = section.title
            titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
            titleLabel.textColor = .black
            
            headerView.addSubview(titleLabel)
            
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
                titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
                titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
                titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
            ])
            
            return headerView
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section = SettingsSection(rawValue: section)!
        if section == .premium {
            return 120
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = SettingsSection(rawValue: indexPath.section)!
        
        switch section {
        case .preferences:
            let item = PreferenceItem(rawValue: indexPath.row)!
            if item == .language {
                // Navigate to language selection
            }
            
        case .other:
            let item = OtherItem(rawValue: indexPath.row)!
            switch item {
            case .shareApp:
                // Share app functionality
                break
            case .rateUs:
                // Rate app functionality
                break
            case .feedback:
                // Feedback functionality
                break
            case .privacyPolicy:
                // Privacy policy functionality
                break
            }
            
        default:
            break
        }
    }
}
