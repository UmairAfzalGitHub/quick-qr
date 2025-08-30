//
//  ContactsView.swift
//  Quick QR
//
//  Created by Haider Rathore on 29/08/2025.
//

import UIKit

final class BarCodeView: UIView {
    // MARK: - Public API
    var urlText: String? {
        get { barCodeTextField.text }
        set { barCodeTextField.text = newValue }
    }

    // MARK: - UI Elements
    private let barCodeNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Bar Code Name"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .textPrimary
        return label
    }()
    
    private let barCodeTextField: UITextField = {
        let tf = PaddedTextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Enter Code"
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
        
        addSubview(barCodeNameLabel)
        addSubview(barCodeTextField)

        let side: CGFloat = 0
        let fieldHeight: CGFloat = 54
        let labelFieldSpacing: CGFloat = 8
        
        NSLayoutConstraint.activate([
            // longitude label
            barCodeNameLabel.topAnchor.constraint(equalTo: topAnchor),
            barCodeNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            barCodeNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -side),
            barCodeNameLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // longitude field
            barCodeTextField.topAnchor.constraint(equalTo: barCodeNameLabel.bottomAnchor, constant: labelFieldSpacing),
            barCodeTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            barCodeTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -side),
            barCodeTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
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
