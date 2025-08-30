//
//  AppButtonView.swift
//  Quick QR
//
//  Created by Umair Afzal on 26/08/2025.
//

import Foundation
import UIKit

enum AppButtonStyle {
    case primary(title: String, image: UIImage? = nil)
    case secondary(title: String, image: UIImage? = nil)
}

final class AppButtonView: UIView {

    // MARK: - Subviews
    private let shadowView = UIView() // Dedicated view for shadow
    private let containerView = UIView()
    private let contentStack = UIStackView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()

    // MARK: - Config
    var tapHandler: (() -> Void)?
    
    // MARK: - Properties
    private var isButtonEnabled: Bool = true
    private var currentStyle: AppButtonStyle?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupGesture()
        
        // Set corner radius after frame is set
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Always set corner radius to half the height for pill shape
        let cornerRadius = containerView.bounds.height / 2
        containerView.layer.cornerRadius = cornerRadius
        
        // Create a shadow path based on the container's bounds
        // This significantly improves shadow rendering performance and visibility
        let shadowPath = UIBezierPath(roundedRect: shadowView.bounds, 
                                     cornerRadius: cornerRadius)
        shadowView.layer.shadowPath = shadowPath.cgPath
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupGesture()
    }

    // MARK: - Setup
    private func setupView() {
        backgroundColor = .clear
        
        // Setup shadow view
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.backgroundColor = .clear
        shadowView.layer.shadowColor = UIColor.appPrimary.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 8)
        shadowView.layer.shadowRadius = 20
        shadowView.layer.shadowOpacity = 0.48
        shadowView.layer.masksToBounds = false
        
        // Setup container view with rounded corners
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.clipsToBounds = true
        
        contentStack.axis = .horizontal
        contentStack.spacing = 8
        contentStack.alignment = .center
        contentStack.distribution = .equalCentering
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)

        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center

        // Add views in the correct order for shadow to be visible
        addSubview(shadowView)
        addSubview(containerView)
        containerView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            // Shadow view constraints - same size as container
            shadowView.topAnchor.constraint(equalTo: containerView.topAnchor),
            shadowView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            shadowView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            shadowView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // Container view constraints
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            
            // Content stack constraints
            contentStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            contentStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            contentStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ])
    }

    private func setupGesture() {
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }

    @objc private func handleTap() {
        if isButtonEnabled {
            tapHandler?()
        }
    }

    // MARK: - Public API
    func setEnabled(_ enabled: Bool) {
        isButtonEnabled = enabled
        
        // Apply visual changes based on enabled state
        if enabled {
            // Restore original appearance based on current style
            if let style = currentStyle {
                applyStyle(style)
            }
            shadowView.layer.shadowOpacity = 0.48
        } else {
            // Apply disabled appearance
            containerView.backgroundColor = UIColor(white: 0.85, alpha: 1.0) // Light grey
            containerView.layer.borderWidth = 0
            titleLabel.textColor = UIColor(white: 0.6, alpha: 1.0) // Darker grey for text
            shadowView.layer.shadowOpacity = 0 // Remove shadow when disabled
        }
    }
    
    func configure(with style: AppButtonStyle) {
        // Store current style for later use when toggling enabled state
        currentStyle = style
        
        // Clear previous views
        contentStack.arrangedSubviews.forEach { contentStack.removeArrangedSubview($0); $0.removeFromSuperview() }
        
        // Apply the style
        applyStyle(style)
        
        // If button is disabled, override with disabled appearance
        if !isButtonEnabled {
            setEnabled(false)
        }
    }
    
    private func applyStyle(_ style: AppButtonStyle) {
        // Update stack distribution based on whether we have an image
        switch style {
        case let .primary(title, image):
            containerView.backgroundColor = UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0) // Bright blue color
            containerView.layer.borderWidth = 0
            
            if let image = image {
                // With image: use fill distribution and add spacer views for centering
                contentStack.distribution = .fill
                
                // Add leading spacer
                let leadingSpacer = UIView()
                leadingSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
                contentStack.addArrangedSubview(leadingSpacer)
                
                // Add image
                imageView.image = image
                imageView.setContentHuggingPriority(.required, for: .horizontal)
                contentStack.addArrangedSubview(imageView)
            } else {
                // No image: use equal centering for automatic centering
                contentStack.distribution = .equalCentering
            }
            
            titleLabel.text = title
            titleLabel.textColor = .white
            contentStack.addArrangedSubview(titleLabel)
            
            if image != nil {
                // Add trailing spacer to balance the leading one
                let trailingSpacer = UIView()
                trailingSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
                contentStack.addArrangedSubview(trailingSpacer)
            }

        case let .secondary(title, image):
            containerView.backgroundColor = UIColor.white
            containerView.layer.borderWidth = 1
            containerView.layer.borderColor = UIColor.systemBlue.cgColor
            
            if let image = image {
                // With image: use fill distribution and add spacer views for centering
                contentStack.distribution = .fill
                
                // Add leading spacer
                let leadingSpacer = UIView()
                leadingSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
                contentStack.addArrangedSubview(leadingSpacer)
                
                // Add image
                imageView.image = image
                imageView.setContentHuggingPriority(.required, for: .horizontal)
                contentStack.addArrangedSubview(imageView)
            } else {
                // No image: use equal centering for automatic centering
                contentStack.distribution = .equalCentering
            }
            
            titleLabel.text = title
            titleLabel.textColor = UIColor.systemBlue
            contentStack.addArrangedSubview(titleLabel)
            
            if image != nil {
                // Add trailing spacer to balance the leading one
                let trailingSpacer = UIView()
                trailingSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
                contentStack.addArrangedSubview(trailingSpacer)
            }
        }
    }
}
