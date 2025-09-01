//
//  WebsiteView.swift
//  Quick QR
//
//  Created by Haider Rathore on 29/08/2025.
//

import UIKit

final class WebsiteView: UIView {
    // MARK: - Public API
    var websiteText: String? {
        get { websiteTextField.text }
        set { websiteTextField.text = newValue }
    }
    
    // MARK: - Getter Methods
    func getURL() -> String? {
        return websiteTextField.text
    }
    
    // MARK: - UI Elements
    private let websiteLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Website URL"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .textPrimary
        return label
    }()
    
    private let websiteTextField: UITextField = {
        let tf = PaddedTextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "http://"
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.clearButtonMode = .whileEditing
        tf.backgroundColor = .systemBackground
        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.appBorderDark.cgColor
        return tf
    }()
    
    private let wwwView: UIButton = {
        let button = UIButton()
        button.setTitle("www.", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.setTitleColor(.textPrimary, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .appSecondaryBackground
        button.layer.cornerRadius = 10
        return button
    }()

    private let comView: UIButton = {
        let button = UIButton()
        button.setTitle(".com", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.setTitleColor(.textPrimary, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .appSecondaryBackground
        button.layer.cornerRadius = 10
        return button
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Private
    private func setup() {
        backgroundColor = .clear
        
        addSubview(websiteLabel)
        addSubview(websiteTextField)
        addSubview(wwwView)
        addSubview(comView)
        
        // Add tap actions
        wwwView.addTarget(self, action: #selector(wwwButtonTapped), for: .touchUpInside)
        comView.addTarget(self, action: #selector(comButtonTapped), for: .touchUpInside)

        let side: CGFloat = 0
        let fieldHeight: CGFloat = 54
        let labelFieldSpacing: CGFloat = 8
        
        NSLayoutConstraint.activate([
            // Email label
            websiteLabel.topAnchor.constraint(equalTo: topAnchor),
            websiteLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            websiteLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -side),
            websiteLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // Email field
            websiteTextField.topAnchor.constraint(equalTo: websiteLabel.bottomAnchor, constant: labelFieldSpacing),
            websiteTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            websiteTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -side),
            websiteTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            wwwView.topAnchor.constraint(equalTo: websiteTextField.bottomAnchor, constant: 24),
            wwwView.leadingAnchor.constraint(equalTo: websiteTextField.leadingAnchor),
            wwwView.heightAnchor.constraint(equalToConstant: 46),
            wwwView.widthAnchor.constraint(equalToConstant: 116),
            
            comView.topAnchor.constraint(equalTo: websiteTextField.bottomAnchor, constant: 24),
            comView.leadingAnchor.constraint(equalTo: wwwView.trailingAnchor, constant: 24),
            comView.heightAnchor.constraint(equalToConstant: 46),
            comView.widthAnchor.constraint(equalToConstant: 116),
            
            // Add bottom constraint to ensure view includes all content
            comView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    // MARK: - Button Actions
    
    @objc private func wwwButtonTapped() {
        guard var text = websiteTextField.text else { return }
        
        // Remove any existing protocol prefixes
        if text.hasPrefix("http://") {
            text = String(text.dropFirst(7))
        } else if text.hasPrefix("https://") {
            text = String(text.dropFirst(8))
        }
        
        // Remove any existing www. prefix to avoid duplication
        if text.hasPrefix("www.") {
            // Already has www prefix, do nothing
            return
        }
        
        // Add www. prefix
        websiteTextField.text = "www." + text
        
        // Give visual feedback
        UIView.animate(withDuration: 0.1, animations: {
            self.wwwView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.wwwView.transform = .identity
            }
        }
    }
    
    @objc private func comButtonTapped() {
        guard var text = websiteTextField.text else { return }
        
        // Check if text already ends with .com
        if text.hasSuffix(".com") {
            // Already has .com suffix, do nothing
            return
        }
        
        // Remove any trailing dots to avoid double dots
        while text.hasSuffix(".") {
            text.removeLast()
        }
        
        // Add .com suffix
        websiteTextField.text = text + ".com"
        
        // Give visual feedback
        UIView.animate(withDuration: 0.1, animations: {
            self.comView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.comView.transform = .identity
            }
        }
    }
}

// MARK: - Helpers
/// A UITextField subclass that adds horizontal padding to match the design.
private final class PaddedTextField: UITextField {
    private let padding = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: padding)
    }
}
