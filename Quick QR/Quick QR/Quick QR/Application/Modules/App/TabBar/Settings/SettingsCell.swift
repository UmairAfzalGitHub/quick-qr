//
//  SettingsCell.swift
//  Quick QR
//
//  Created by Umair Afzal on 29/08/2025.
//

import Foundation
import UIKit

// MARK: - Cell Classes
protocol SettingsCellDelegate: AnyObject {
    func settingsCell(_ cell: SettingsCell, didChangeSwitchValue isOn: Bool, forTag tag: Int)
}

class SettingsCell: UITableViewCell {
    static let identifier = "SettingsCell"
    
    enum AccessoryType {
        case toggle(isOn: Bool)
        case navigation
    }
    
    // MARK: - Properties
    weak var delegate: SettingsCellDelegate?
    private let iconContainer = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let toggleSwitch = UISwitch()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Icon container
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.layer.cornerRadius = 16
        contentView.addSubview(iconContainer)
        
        // Icon
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconContainer.addSubview(iconImageView)
        
        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        contentView.addSubview(titleLabel)
        
        // Switch
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitch.onTintColor = .systemBlue
        toggleSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        toggleSwitch.isHidden = true
        contentView.addSubview(toggleSwitch)
        
        // Layout
        NSLayoutConstraint.activate([
            iconContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 32),
            iconContainer.heightAnchor.constraint(equalToConstant: 32),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            toggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    // MARK: - Configuration
    func configure(with title: String, icon: UIImage?, accessoryType: AccessoryType, tag: Int = 0) {
        titleLabel.text = title
        iconImageView.image = icon
        
        switch accessoryType {
        case .toggle(let isOn):
            selectionStyle = .none
            self.accessoryType = .none
            toggleSwitch.isHidden = false
            toggleSwitch.isOn = isOn
            toggleSwitch.tag = tag
            
        case .navigation:
            selectionStyle = .default
            self.accessoryType = .disclosureIndicator
            toggleSwitch.isHidden = true
        }
    }
    
    // MARK: - Actions
    @objc private func switchValueChanged(_ sender: UISwitch) {
        delegate?.settingsCell(self, didChangeSwitchValue: sender.isOn, forTag: sender.tag)
    }
}
