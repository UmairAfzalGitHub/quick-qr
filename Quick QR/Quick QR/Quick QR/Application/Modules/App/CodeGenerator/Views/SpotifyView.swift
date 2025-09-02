//
//  ContactsView.swift
//  Quick QR
//
//  Created by Haider Rathore on 29/08/2025.
//

import UIKit

final class SpotifyView: UIView {
    // MARK: - Public API
    var urlText: String? {
        get { urlTextField.text }
        set { urlTextField.text = newValue }
    }
    
    // MARK: - Getter Methods
    func getUsername() -> String? {
        return urlTextField.text
    }
    
    func getUrl() -> String? {
        return urlTextField.text
    }
    
    // MARK: - Setter Methods
    func setUsername(_ username: String) {
        urlTextField.text = username
    }
    
    func setUrl(_ url: String) {
        urlTextField.text = url
    }
    
    // MARK: - Data Population Methods
    func populateData(username: String = "", url: String = "") {
        if !url.isEmpty {
            setUrl(url)
        } else if !username.isEmpty {
            setUsername(username)
        }
    }
    
    /// Parse and populate Spotify data from a QR code content string
    /// - Parameter content: The Spotify content string (URL or username)
    /// - Returns: True if the content was successfully parsed, false otherwise
    @discardableResult
    func parseAndPopulateFromContent(_ content: String) -> Bool {
        if content.contains("spotify.com") {
            populateData(url: content)
        } else {
            populateData(username: content)
        }
        return true
    }

    // MARK: - UI Elements
    private let urlLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "URL"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .textPrimary
        return label
    }()
    
    private let urlTextField: UITextField = {
        let tf = PaddedTextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Enter URL"
        tf.keyboardType = .URL
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
        addSubview(urlTextField)

        let side: CGFloat = 0
        let fieldHeight: CGFloat = 54
        let labelFieldSpacing: CGFloat = 8
        
        NSLayoutConstraint.activate([
            // longitude label
            urlLabel.topAnchor.constraint(equalTo: topAnchor),
            urlLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            urlLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -side),
            urlLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // longitude field
            urlTextField.topAnchor.constraint(equalTo: urlLabel.bottomAnchor, constant: labelFieldSpacing),
            urlTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            urlTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -side),
            urlTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
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
