//
//  EmailView.swift
//  Quick QR
//
//  Created by Haider Rathore on 28/08/2025.
//

import UIKit

/// A UIKit-based view that replicates the provided design for composing an email.
/// It contains three sections:
/// 1. "Email address" with a single-line text field
/// 2. "Subject" with a single-line text field
/// 3. "Content" with a multi-line text view and placeholder
/// No scroll view is used; layout is done with Auto Layout constraints.
final class EmailView: UIView {
    // MARK: - Public API
    var emailText: String? {
        get { emailTextField.text }
        set { emailTextField.text = newValue }
    }
    
    var subjectText: String? {
        get { subjectTextField.text }
        set { subjectTextField.text = newValue }
    }
    
    var contentText: String? {
        get { contentTextView.text.isEmpty ? nil : contentTextView.text }
        set {
            contentTextView.text = newValue
            updateContentPlaceholder()
        }
    }
    
    // MARK: - Getter Methods
    func getEmail() -> String? {
        return emailTextField.text
    }
    
    func getSubject() -> String? {
        return subjectTextField.text
    }
    
    func getBody() -> String? {
        return contentTextView.text.isEmpty ? nil : contentTextView.text
    }
    
    // MARK: - UI Elements
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
        tf.placeholder = "Enter name"
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
    
    private let subjectLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Subject"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .textPrimary
        return label
    }()
    
    private let subjectTextField: UITextField = {
        let tf = PaddedTextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Please enter something"
        tf.autocapitalizationType = .sentences
        tf.autocorrectionType = .yes
        tf.backgroundColor = .systemBackground
        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.appBorderDark.cgColor
        return tf
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Content"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .textPrimary
        return label
    }()
    
    private let contentContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 10
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.appBorderDark.cgColor
        return v
    }()
    
    private let contentTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.textColor = .label
        tv.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        tv.isScrollEnabled = true // internal scrolling for long content, while no UIScrollView is added externally
        return tv
    }()
    
    private let contentPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Please enter something"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.placeholderText
        return label
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
        
        addSubview(emailLabel)
        addSubview(emailTextField)
        addSubview(subjectLabel)
        addSubview(subjectTextField)
        addSubview(contentLabel)
        addSubview(contentContainer)
        contentContainer.addSubview(contentTextView)
        contentContainer.addSubview(contentPlaceholderLabel)
        
        contentTextView.delegate = self
        
        let side: CGFloat = 0
        let fieldHeight: CGFloat = 54
        let sectionSpacing: CGFloat = 16
        let labelFieldSpacing: CGFloat = 8
        
        NSLayoutConstraint.activate([
            // Email label
            emailLabel.topAnchor.constraint(equalTo: topAnchor),
            emailLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            emailLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -side),
            emailLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // Email field
            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: labelFieldSpacing),
            emailTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            emailTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -side),
            emailTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            // Subject label
            subjectLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: sectionSpacing),
            subjectLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            subjectLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -side),
            subjectLabel.heightAnchor.constraint(equalToConstant: 24),
            

            // Subject field
            subjectTextField.topAnchor.constraint(equalTo: subjectLabel.bottomAnchor, constant: labelFieldSpacing),
            subjectTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            subjectTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -side),
            subjectTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            // Content label
            contentLabel.topAnchor.constraint(equalTo: subjectTextField.bottomAnchor, constant: sectionSpacing),
            contentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            contentLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -side),
            contentLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // Content container
            contentContainer.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: labelFieldSpacing),
            contentContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            contentContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -side),
            contentContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 140),
            contentContainer.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            
            // Text view inside container
            contentTextView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            contentTextView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            contentTextView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            contentTextView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
            
            // Placeholder label inside container (aligned with text inset)
            contentPlaceholderLabel.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 12),
            contentPlaceholderLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 16),
            contentPlaceholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentContainer.trailingAnchor, constant: -16)
        ])
        
        updateContentPlaceholder()
    }
    
    private func updateContentPlaceholder() {
        contentPlaceholderLabel.isHidden = !(contentTextView.text?.isEmpty ?? true)
    }
}

// MARK: - UITextViewDelegate
extension EmailView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateContentPlaceholder()
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
