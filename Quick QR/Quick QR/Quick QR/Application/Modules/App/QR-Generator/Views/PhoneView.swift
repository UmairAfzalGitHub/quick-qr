//
//  PhoneView.swift
//  Quick QR
//
//  Created by Haider Rathore on 29/08/2025.
//

import UIKit

final class PhoneView: UIView {
    // MARK: - Public API
    var phoneNumberText: String? {
        get { phoneTextField.text }
        set { phoneTextField.text = newValue }
    }
    
    // MARK: - UI Elements
    private let phoneLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Phone Number"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .textPrimary
        return label
    }()
    
    private let phoneTextField: UITextField = {
        let tf = PaddedTextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Enter phone number"
        tf.keyboardType = .phonePad
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.clearButtonMode = .whileEditing
        tf.backgroundColor = .systemBackground
        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.appBorderDark.cgColor
        return tf
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
        
        addSubview(phoneLabel)
        addSubview(phoneTextField)

        let side: CGFloat = 0
        let fieldHeight: CGFloat = 50
        let labelFieldSpacing: CGFloat = 8
        
        NSLayoutConstraint.activate([
            // Phone label
            phoneLabel.topAnchor.constraint(equalTo: topAnchor),
            phoneLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            phoneLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -side),
            phoneLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // Phone field
            phoneTextField.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: labelFieldSpacing),
            phoneTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            phoneTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -side),
            phoneTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
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
