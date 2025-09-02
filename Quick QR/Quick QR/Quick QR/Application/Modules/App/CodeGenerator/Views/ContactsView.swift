//
//  ContactsView.swift
//  Quick QR
//
//  Created by Haider Rathore on 29/08/2025.
//

import UIKit

final class ContactsView: UIView {
    // MARK: - Public API
    var nameText: String? {
        get { nameTextField.text }
        set { nameTextField.text = newValue }
    }
    
    var numberText: String? {
        get { numberTextField.text }
        set { numberTextField.text = newValue }
    }
    
    var emailText: String? {
        get { emailTextField.text }
        set { emailTextField.text = newValue }
    }
    
    // MARK: - Getter Methods
    func getName() -> String? {
        return nameTextField.text
    }
    
    func getPhone() -> String? {
        return numberTextField.text
    }
    
    func getEmail() -> String? {
        return emailTextField.text
    }
    
    // MARK: - Setter Methods
    func setName(_ name: String) {
        nameTextField.text = name
    }
    
    func setPhone(_ phone: String) {
        numberTextField.text = phone
    }
    
    func setEmail(_ email: String) {
        emailTextField.text = email
    }
    
    // MARK: - Data Population Methods
    func populateData(name: String, phone: String, email: String) {
        setName(name)
        setPhone(phone)
        setEmail(email)
    }
    
    /// Parse and populate contact data from a QR code content string
    /// - Parameter content: The vCard content string (BEGIN:VCARD...END:VCARD)
    /// - Returns: True if the content was successfully parsed, false otherwise
    @discardableResult
    func parseAndPopulateFromContent(_ content: String) -> Bool {
        if content.hasPrefix("BEGIN:VCARD") {
            let lines = content.components(separatedBy: .newlines)
            var name = ""
            var phone = ""
            var email = ""
            
            for line in lines {
                if line.hasPrefix("FN:") {
                    name = String(line.dropFirst(3))
                } else if line.hasPrefix("TEL:") {
                    phone = String(line.dropFirst(4))
                } else if line.hasPrefix("EMAIL:") {
                    email = String(line.dropFirst(6))
                }
            }
            
            populateData(name: name, phone: phone, email: email)
            return true
        }
        return false
    }
    
    // MARK: - UI Elements
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Name"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .textPrimary
        return label
    }()
    
    private let nameTextField: UITextField = {
        let tf = PaddedTextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Enter name"
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
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Phone number"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .textPrimary
        return label
    }()
    
    private let numberTextField: UITextField = {
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
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Email address"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .textPrimary
        return label
    }()
    
    private let emailTextField: UITextField = {
        let tf = PaddedTextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Enter email address"
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
        
        addSubview(nameLabel)
        addSubview(nameTextField)
        addSubview(numberLabel)
        addSubview(numberTextField)
        addSubview(emailLabel)
        addSubview(emailTextField)

        let side: CGFloat = 0
        let fieldHeight: CGFloat = 54
        let sectionSpacing: CGFloat = 16
        let labelFieldSpacing: CGFloat = 8
        
        NSLayoutConstraint.activate([
            // name label
            nameLabel.topAnchor.constraint(equalTo: topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -side),
            nameLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // name field
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: labelFieldSpacing),
            nameTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            nameTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -side),
            nameTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            // number label
            numberLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: sectionSpacing),
            numberLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            numberLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -side),
            numberLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // number field
            numberTextField.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: labelFieldSpacing),
            numberTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            numberTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -side),
            numberTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            // email label
            emailLabel.topAnchor.constraint(equalTo: numberTextField.bottomAnchor, constant: sectionSpacing),
            emailLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            emailLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -side),
            emailLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // email field
            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: labelFieldSpacing),
            emailTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            emailTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -side),
            emailTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            // Add bottom constraint to ensure view includes all fields
            emailTextField.bottomAnchor.constraint(equalTo: bottomAnchor),
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
