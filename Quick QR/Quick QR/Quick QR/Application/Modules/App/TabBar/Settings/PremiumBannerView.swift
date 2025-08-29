//
//  PremiumBannerView.swift
//  Quick QR
//
//  Created by Umair Afzal on 29/08/2025.
//

import Foundation
import UIKit

// MARK: - PremiumBannerView
class PremiumBannerView: UIView {
    
    // MARK: - Properties
    private let containerView = UIView()
    private let diamondImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let upgradeButton = UIButton(type: .system)
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        
        // Container view
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor(red: 1.0, green: 0.95, blue: 0.85, alpha: 1.0) // Light peach color
        containerView.layer.cornerRadius = 12
        addSubview(containerView)
        
        // Diamond image
        diamondImageView.translatesAutoresizingMaskIntoConstraints = false
        diamondImageView.contentMode = .scaleAspectFit
        diamondImageView.image = UIImage(systemName: "diamond.fill")
        diamondImageView.tintColor = .systemYellow
        containerView.addSubview(diamondImageView)
        
        // Title label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Go Premium"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .systemOrange
        containerView.addSubview(titleLabel)
        
        // Subtitle label
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Get 100% Ads-Free experience"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .darkGray
        containerView.addSubview(subtitleLabel)
        
        // Upgrade button
        upgradeButton.translatesAutoresizingMaskIntoConstraints = false
        upgradeButton.setTitle("Upgrade now", for: .normal)
        upgradeButton.setTitleColor(.white, for: .normal)
        upgradeButton.backgroundColor = .systemOrange
        upgradeButton.layer.cornerRadius = 15
        upgradeButton.addTarget(self, action: #selector(upgradeButtonTapped), for: .touchUpInside)
        containerView.addSubview(upgradeButton)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            diamondImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            diamondImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            diamondImageView.widthAnchor.constraint(equalToConstant: 40),
            diamondImageView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.leadingAnchor.constraint(equalTo: diamondImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            upgradeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            upgradeButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            upgradeButton.widthAnchor.constraint(equalToConstant: 120),
            upgradeButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    // MARK: - Actions
    @objc private func upgradeButtonTapped() {
        // Handle upgrade button tap
    }
}

