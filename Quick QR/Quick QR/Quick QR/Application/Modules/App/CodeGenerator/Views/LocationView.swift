//
//  ContactsView.swift
//  Quick QR
//
//  Created by Haider Rathore on 29/08/2025.
//

import UIKit

final class LocationView: UIView {
    // MARK: - Public API
    var latitudeText: String? {
        get { latitudeTextField.text }
        set { latitudeTextField.text = newValue }
    }
    
    var longitudeText: String? {
        get { longitudeTextField.text }
        set { longitudeTextField.text = newValue }
    }
    
    // MARK: - Getter Methods
    func getLatitude() -> String? {
        return latitudeTextField.text
    }
    
    func getLongitude() -> String? {
        return longitudeTextField.text
    }
    
    // MARK: - Setter Methods
    func setLatitude(_ latitude: String) {
        latitudeTextField.text = latitude
    }
    
    func setLongitude(_ longitude: String) {
        longitudeTextField.text = longitude
    }
    
    // MARK: - Data Population Methods
    func populateData(latitude: String, longitude: String) {
        setLatitude(latitude)
        setLongitude(longitude)
    }
    
    /// Parse and populate location data from a QR code content string
    /// - Parameter content: The location content string (geo:latitude,longitude)
    /// - Returns: True if the content was successfully parsed, false otherwise
    @discardableResult
    func parseAndPopulateFromContent(_ content: String) -> Bool {
        if content.hasPrefix("geo:") {
            let coordinates = String(content.dropFirst(4)).components(separatedBy: ",")
            if coordinates.count >= 2 {
                populateData(latitude: coordinates[0], longitude: coordinates[1])
                return true
            }
        }
        return false
    }

    // MARK: - UI Elements
    private let latitudeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Latitude"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .textPrimary
        return label
    }()
    
    private let latitudeTextField: UITextField = {
        let tf = PaddedTextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Enter lonngitude of location"
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
    
    private let longitudeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Longitude"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .textPrimary
        return label
    }()
    
    private let longitudeTextField: UITextField = {
        let tf = PaddedTextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Enter lonngitude of location"
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
        
        addSubview(latitudeLabel)
        addSubview(latitudeTextField)
        addSubview(longitudeLabel)
        addSubview(longitudeTextField)

        let side: CGFloat = 0
        let fieldHeight: CGFloat = 54
        let sectionSpacing: CGFloat = 16
        let labelFieldSpacing: CGFloat = 8
        
        NSLayoutConstraint.activate([
            // latitude label
            latitudeLabel.topAnchor.constraint(equalTo: topAnchor),
            latitudeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            latitudeLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -side),
            latitudeLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // latitude field
            latitudeTextField.topAnchor.constraint(equalTo: latitudeLabel.bottomAnchor, constant: labelFieldSpacing),
            latitudeTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            latitudeTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -side),
            latitudeTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            // longitude label
            longitudeLabel.topAnchor.constraint(equalTo: latitudeTextField.bottomAnchor, constant: sectionSpacing),
            longitudeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            longitudeLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -side),
            longitudeLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // longitude field
            longitudeTextField.topAnchor.constraint(equalTo: longitudeLabel.bottomAnchor, constant: labelFieldSpacing),
            longitudeTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            longitudeTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -side),
            longitudeTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
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
