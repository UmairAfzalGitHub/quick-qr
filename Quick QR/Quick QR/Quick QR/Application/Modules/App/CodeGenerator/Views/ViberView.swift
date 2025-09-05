//
//  ContactsView.swift
//  Quick QR
//
//  Created by Haider Rathore on 29/08/2025.
//

import UIKit

final class ViberView: UIView {
    // MARK: - Public API
    var urlText: String? {
        get { phoneNumberTextField.text }
        set { phoneNumberTextField.text = newValue }
    }
    
    // MARK: - Getter Methods
    func getPhoneNumber() -> String? {
        guard let phoneNumber = phoneNumberTextField.text, !phoneNumber.isEmpty else { return nil }
        let countryCode = codeLabel.text?.trimmingCharacters(in: .whitespaces) ?? "+1"
        return countryCode + phoneNumber
    }
    
    // MARK: - Setter Methods
    func setPhoneNumber(_ phoneNumber: String) {
        // Check if the phone number starts with a country code
        if phoneNumber.hasPrefix("+") {
            // Try to extract country code and number
            if let countryCodeRange = phoneNumber.range(of: "\\+\\d+", options: .regularExpression) {
                let countryCode = String(phoneNumber[countryCodeRange])
                codeLabel.text = countryCode
                
                // Set the remaining part as the phone number
                let numberStartIndex = phoneNumber.index(after: countryCodeRange.upperBound)
                if numberStartIndex < phoneNumber.endIndex {
                    let number = String(phoneNumber[numberStartIndex...])
                    phoneNumberTextField.text = number
                } else {
                    phoneNumberTextField.text = ""
                }
            } else {
                // If we can't parse it properly, just set the whole thing as the number
                phoneNumberTextField.text = phoneNumber
            }
        } else {
            // No country code, just set the number
            phoneNumberTextField.text = phoneNumber
        }
    }
    
    // MARK: - Data Population Methods
    func populateData(phoneNumber: String = "") {
        if !phoneNumber.isEmpty {
            setPhoneNumber(phoneNumber)
        }
    }
    
    /// Parse and populate Viber data from a QR code content string
    /// - Parameter content: The Viber content string (URL or phone number)
    /// - Returns: True if the content was successfully parsed, false otherwise
    @discardableResult
    func parseAndPopulateFromContent(_ content: String) -> Bool {
        if content.hasPrefix("viber://") {
            let phoneNumber = String(content.dropFirst(8))
            populateData(phoneNumber: phoneNumber)
        } else {
            populateData(phoneNumber: content)
        }
        return true
    }

    // MARK: - UI Elements
    private let urlLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Strings.Label.phoneNumber
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .textPrimary
        return label
    }()
    
    private let codeSelectorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.separator.cgColor
        return view
    }()
    
    private let codeSelectorStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 4
        return stackView
    }()
    
    private let codeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "+1"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.placeholderText
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "arrow-down"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.tintColor = .placeholderText
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private let phoneNumberTextField: UITextField = {
        let tf = PaddedTextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = Strings.Label.enterPhoneNumber
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
        
        addSubview(urlLabel)
        addSubview(phoneNumberTextField)
        addSubview(codeSelectorView)
        codeSelectorView.addSubview(codeSelectorStackView)
        codeSelectorStackView.addArrangedSubview(codeLabel)
        codeSelectorStackView.addArrangedSubview(arrowImageView)

        let side: CGFloat = 0
        let fieldHeight: CGFloat = 54
        let labelFieldSpacing: CGFloat = 8
        
        NSLayoutConstraint.activate([
            urlLabel.topAnchor.constraint(equalTo: topAnchor),
            urlLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            urlLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -side),
            urlLabel.heightAnchor.constraint(equalToConstant: 24),
            
            codeSelectorView.topAnchor.constraint(equalTo: urlLabel.bottomAnchor, constant: labelFieldSpacing),
            codeSelectorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            codeSelectorView.heightAnchor.constraint(equalToConstant: fieldHeight),
            codeSelectorView.widthAnchor.constraint(equalToConstant: 90),
            
            phoneNumberTextField.centerYAnchor.constraint(equalTo: codeSelectorView.centerYAnchor),
            phoneNumberTextField.leadingAnchor.constraint(equalTo: codeSelectorView.trailingAnchor, constant: 10),
            phoneNumberTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -side),
            phoneNumberTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            codeSelectorStackView.topAnchor.constraint(equalTo: codeSelectorView.topAnchor),
            codeSelectorStackView.leadingAnchor.constraint(equalTo: codeSelectorView.leadingAnchor, constant: 12),
            codeSelectorStackView.trailingAnchor.constraint(equalTo: codeSelectorView.trailingAnchor, constant: -12),
            codeSelectorStackView.bottomAnchor.constraint(equalTo: codeSelectorView.bottomAnchor),
            
            
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
