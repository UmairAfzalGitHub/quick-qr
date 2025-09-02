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
    
    // MARK: - Getter Methods
    func getSSID() -> String? {
        return ssIDTextField.text
    }
    
    func getPassword() -> String? {
        return passwordTextField.text
    }
    
    func isWEP() -> Bool {
        // Check if WEP button is selected
        return wepButton.backgroundColor == .appPrimary
    }
    
    // MARK: - Setter Methods
    func setSSID(_ ssid: String) {
        // Remove any 'SSID:' prefix if present
        if ssid.hasPrefix("SSID:") {
            let cleanedSSID = ssid.dropFirst(5).trimmingCharacters(in: .whitespacesAndNewlines)
            ssIDTextField.text = cleanedSSID
        } else {
            ssIDTextField.text = ssid
        }
    }
    
    func setPassword(_ password: String) {
        // Remove any 'Password:' prefix if present
        if password.hasPrefix("Password:") {
            let cleanedPassword = password.dropFirst(9).trimmingCharacters(in: .whitespacesAndNewlines)
            passwordTextField.text = cleanedPassword
        } else {
            passwordTextField.text = password
        }
    }
    
    func setWEP(_ isWep: Bool) {
        selectSecurityMode(isWep ? .wep : .wpa)
    }
    
    // MARK: - Data Population Methods
    func populateData(ssid: String, password: String, isWep: Bool) {
        setSSID(ssid)
        setPassword(password)
        setWEP(isWep)
    }
    
    /// Parse and populate WiFi data from a QR code content string
    /// - Parameter content: The WiFi QR code content string (WIFI:S:<SSID>;P:<PASSWORD>;T:<WEP/WPA/WPA2>;)
    /// - Returns: True if the content was successfully parsed, false otherwise
    @discardableResult
    func parseAndPopulateFromContent(_ content: String) -> Bool {
        // Check if content is in standard WiFi QR code format
        if content.hasPrefix("WIFI:") {
            let components = content.components(separatedBy: ";").filter { !$0.isEmpty }
            var ssid = ""
            var password = ""
            var isWep = false
            
            for component in components {
                if component.hasPrefix("S:") {
                    ssid = String(component.dropFirst(2))
                } else if component.hasPrefix("P:") {
                    password = String(component.dropFirst(2))
                } else if component.hasPrefix("T:WEP") {
                    isWep = true
                }
            }
            
            populateData(ssid: ssid, password: password, isWep: isWep)
            return true
        } 
        // If content is not in standard format, try to parse it as raw data
        // This handles cases where the content might be stored differently in history
        else {
            // Try to decode JSON format if present
            if let data = content.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                
                // Extract the actual WiFi data from JSON
                if let ssid = json["ssid"] as? String,
                   let password = json["password"] as? String,
                   let isWep = json["isWep"] as? Bool {
                    // Use the actual values stored in JSON
                    populateData(ssid: ssid, password: password, isWep: isWep)
                    return true
                }
                
                // Fallback: Try to extract from displayText if actual values aren't available
                if let displayText = json["displayText"] as? String {
                    // Parse the display text format: "SSID: xxx, Password: <hidden>, Security: xxx"
                    let components = displayText.components(separatedBy: ", ")
                    var extractedSsid = ""
                    var extractedPassword = ""
                    var extractedIsWep = false
                    
                    for component in components {
                        if component.hasPrefix("SSID: ") {
                            extractedSsid = String(component.dropFirst(6))
                        } else if component.hasPrefix("Password: ") {
                            // Note: This will be <hidden> or <none>, but we'll use it as a fallback
                            extractedPassword = String(component.dropFirst(10))
                        } else if component.hasPrefix("Security: ") {
                            extractedIsWep = component.contains("WEP")
                        }
                    }
                    
                    if !extractedSsid.isEmpty {
                        populateData(ssid: extractedSsid, password: extractedPassword, isWep: extractedIsWep)
                        return true
                    }
                }
            }
            
            // Try to parse as a simple string representation
            let components = content.components(separatedBy: ",")
            if components.count >= 2 {
                let ssid = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let password = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
                let isWep = components.count > 2 ? (components[2].lowercased() == "wep") : false
                
                populateData(ssid: ssid, password: password, isWep: isWep)
                return true
            }
            
            // If all else fails, just use the content as the SSID
            if !content.isEmpty {
                populateData(ssid: content, password: "", isWep: false)
                return true
            }
            
            return false
        }
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
        
        // Set default security mode
        selectSecurityMode(.wpa)

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
        
        // Add button actions
        wpaButton.addTarget(self, action: #selector(wpaButtonTapped), for: .touchUpInside)
        wepButton.addTarget(self, action: #selector(wepButtonTapped), for: .touchUpInside)
        noneButton.addTarget(self, action: #selector(noneButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Button Actions
    @objc private func wpaButtonTapped() {
        selectSecurityMode(.wpa)
    }
    
    @objc private func wepButtonTapped() {
        selectSecurityMode(.wep)
    }
    
    @objc private func noneButtonTapped() {
        selectSecurityMode(.none)
    }
    
    // MARK: - Helper Methods
    private enum SecurityMode {
        case wpa, wep, none
    }
    
    private func selectSecurityMode(_ mode: SecurityMode) {
        // Reset all buttons
        wpaButton.backgroundColor = .appSecondaryBackground
        wpaButton.setTitleColor(.textPrimary, for: .normal)
        wepButton.backgroundColor = .appSecondaryBackground
        wepButton.setTitleColor(.textPrimary, for: .normal)
        noneButton.backgroundColor = .appSecondaryBackground
        noneButton.setTitleColor(.textPrimary, for: .normal)
        
        // Highlight selected button
        switch mode {
        case .wpa:
            wpaButton.backgroundColor = .appPrimary
            wpaButton.setTitleColor(.white, for: .normal)
        case .wep:
            wepButton.backgroundColor = .appPrimary
            wepButton.setTitleColor(.white, for: .normal)
        case .none:
            noneButton.backgroundColor = .appPrimary
            noneButton.setTitleColor(.white, for: .normal)
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
