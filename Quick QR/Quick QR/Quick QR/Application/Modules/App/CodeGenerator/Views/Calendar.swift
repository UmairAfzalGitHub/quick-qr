//
//  EmailView.swift
//  Quick QR
//
//  Created by Haider Rathore on 28/08/2025.
//

import UIKit

final class CalendarView: UIView {
    // MARK: - Public API
    var titleText: String? {
        get { titleTextField.text }
        set { titleTextField.text = newValue }
    }
    
    var locationText: String? {
        get { locationTextField.text }
        set { locationTextField.text = newValue }
    }
    
    var dayStartText: String? {
        get { contentTextView.text.isEmpty ? nil : contentTextView.text }
        set {
            contentTextView.text = newValue
            updateContentPlaceholder()
        }
    }
    
    var dayEndText: String? {
        get { contentTextView.text.isEmpty ? nil : contentTextView.text }
        set {
            contentTextView.text = newValue
            updateContentPlaceholder()
        }
    }
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .textPrimary
        return label
    }()
    
    private let titleTextField: UITextField = {
        let tf = PaddedTextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Enter a title"
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
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Location"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .textPrimary
        return label
    }()
    
    private let locationTextField: UITextField = {
        let tf = PaddedTextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Please enter something"
        tf.autocapitalizationType = .sentences
        tf.autocorrectionType = .no
        tf.backgroundColor = .systemBackground
        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.appBorderDark.cgColor
        return tf
    }()
    
    private let allDayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "All day"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .textPrimary
        return label
    }()
    
    private let allDaySwitch: UISwitch = {
        let switchToogle = UISwitch()
        switchToogle.translatesAutoresizingMaskIntoConstraints = false
        switchToogle.backgroundColor = .clear
        switchToogle.onTintColor = .appPrimary
        return switchToogle
    }()
    
    private let startTextField: UITextField = {
        let tf = PaddedTextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Start time"
        tf.autocapitalizationType = .sentences
        tf.autocorrectionType = .no
        tf.backgroundColor = .systemBackground
        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.appBorderDark.cgColor
        return tf
    }()
    
    private let endTextField: UITextField = {
        let tf = PaddedTextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "End time"
        tf.autocapitalizationType = .sentences
        tf.autocorrectionType = .no
        tf.backgroundColor = .systemBackground
        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.appBorderDark.cgColor
        return tf
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Description"
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
        tv.isScrollEnabled = true
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
        
        addSubview(titleLabel)
        addSubview(titleTextField)
        addSubview(locationLabel)
        addSubview(locationTextField)
        addSubview(allDayLabel)
        addSubview(allDaySwitch)
        addSubview(startTextField)
        addSubview(endTextField)
        addSubview(descriptionLabel)
        addSubview(contentContainer)
        contentContainer.addSubview(contentTextView)
        contentContainer.addSubview(contentPlaceholderLabel)
        
        contentTextView.delegate = self
        
        let side: CGFloat = 0
        let fieldHeight: CGFloat = 54
        let sectionSpacing: CGFloat = 16
        let labelFieldSpacing: CGFloat = 8
        
        NSLayoutConstraint.activate([
            // title label
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -side),
            titleLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // title field
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: labelFieldSpacing),
            titleTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            titleTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -side),
            titleTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            // location label
            locationLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: sectionSpacing),
            locationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            locationLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -side),
            locationLabel.heightAnchor.constraint(equalToConstant: 24),
            

            // location field
            locationTextField.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: labelFieldSpacing),
            locationTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            locationTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -side),
            locationTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            // all Day label
            allDayLabel.topAnchor.constraint(equalTo: locationTextField.bottomAnchor, constant: sectionSpacing),
            allDayLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            allDayLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -side),
            allDayLabel.heightAnchor.constraint(equalToConstant: 24),
            
            allDaySwitch.centerYAnchor.constraint(equalTo: allDayLabel.centerYAnchor),
            allDaySwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            
            startTextField.topAnchor.constraint(equalTo: allDayLabel.bottomAnchor, constant: labelFieldSpacing),
            startTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            startTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -side),
            startTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            endTextField.topAnchor.constraint(equalTo: startTextField.bottomAnchor, constant: labelFieldSpacing),
            endTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            endTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -side),
            endTextField.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            // Content label
            descriptionLabel.topAnchor.constraint(equalTo: endTextField.bottomAnchor, constant: sectionSpacing),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: side),
            descriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -side),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // Content container
            contentContainer.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: labelFieldSpacing),
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
extension CalendarView: UITextViewDelegate {
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
