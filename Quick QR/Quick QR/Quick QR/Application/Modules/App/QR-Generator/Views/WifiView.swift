//
//  WebsiteView.swift
//  Quick QR
//
//  Created by Haider Rathore on 29/08/2025.
//

import UIKit

final class WifiView: UIView {
    // MARK: - Public API
    var websiteText: String? {
        get { ssIDTextField.text }
        set { ssIDTextField.text = newValue }
    }
    
    // MARK: - UI Elements
    private let ssIDLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Network Name SSID"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .textPrimary
        return label
    }()
    
    private let ssIDTextField: UITextField = {
        let tf = PaddedTextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Enter SSID"
        tf.keyboardType = .namePhonePad
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.clearButtonMode = .whileEditing
        tf.backgroundColor = .systemBackground
        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.appBorderDark.cgColor
        return tf
    }()
    
    private let passwordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Password"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .textPrimary
        return label
    }()
    
    private let passwordTextField: UITextField = {
        let tf = PaddedTextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Enter Password"
        tf.keyboardType = .namePhonePad
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.clearButtonMode = .whileEditing
        tf.backgroundColor = .systemBackground
        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.appBorderDark.cgColor
        return tf
    }()
    
    private let securityModeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Security Mode"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .textPrimary
        return label
    }()
    
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let wpaButton: UIButton = {
        let button = UIButton()
        button.setTitle("WPA/WPA2", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.setTitleColor(.textPrimary, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .appSecondaryBackground
        button.layer.cornerRadius = 10
        return button
    }()

    private let wepButton: UIButton = {
        let button = UIButton()
        button.setTitle("WEP", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.setTitleColor(.textPrimary, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .appSecondaryBackground
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let noneButton: UIButton = {
        let button = UIButton()
        button.setTitle("None", for: .normal)
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
        
        addSubview(ssIDLabel)
        addSubview(ssIDTextField)
        addSubview(passwordLabel)
        addSubview(passwordTextField)
        addSubview(securityModeLabel)
        addSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(wpaButton)
        buttonsStackView.addArrangedSubview(wepButton)
        buttonsStackView.addArrangedSubview(noneButton)

        let side: CGFloat = 0
        let fieldHeight: CGFloat = 54
        let labelFieldSpacing: CGFloat = 8
        
        NSLayoutConstraint.activate([
            // Email label
            ssIDLabel.topAnchor.constraint(equalTo: topAnchor),
            ssIDLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            ssIDLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -side),
            ssIDLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // Email field
            ssIDTextField.topAnchor.constraint(equalTo: ssIDLabel.bottomAnchor, constant: labelFieldSpacing),
            ssIDTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            ssIDTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -side),
            ssIDTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            passwordLabel.topAnchor.constraint(equalTo: ssIDTextField.bottomAnchor, constant: 24),
            passwordLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            passwordLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -side),
            passwordLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // Email field
            passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: labelFieldSpacing),
            passwordTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            passwordTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -side),
            passwordTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            securityModeLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 24),
            securityModeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            securityModeLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -side),
            securityModeLabel.heightAnchor.constraint(equalToConstant: 24),
            
            buttonsStackView.topAnchor.constraint(equalTo: securityModeLabel.bottomAnchor, constant: labelFieldSpacing),
            buttonsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            buttonsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -side),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 46),
        ])
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
