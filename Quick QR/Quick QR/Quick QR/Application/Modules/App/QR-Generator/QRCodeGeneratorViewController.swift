//
//  QRCodeGeneratorViewController.swift
//  Quick QR
//
//  Created by Haider Rathore on 28/08/2025.
//

import UIKit

class QRCodeGeneratorViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let actionButton = UIButton(type: .system)
    private let adContainerView = UIView()
    
    // MARK: - Properties
    var buttonTitle: String = "Action" {
        didSet {
            actionButton.setTitle(buttonTitle, for: .normal)
        }
    }
    
    var buttonAction: (() -> Void)?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Configure scroll view
        scrollView.backgroundColor = .cyan
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        
        // Configure content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure action button
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.setTitle(buttonTitle, for: .normal)
        actionButton.backgroundColor = .systemBlue
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.layer.cornerRadius = 8
        actionButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        // Configure ad container
        adContainerView.translatesAutoresizingMaskIntoConstraints = false
        adContainerView.backgroundColor = .systemGray6
        adContainerView.layer.cornerRadius = 8
        adContainerView.layer.borderWidth = 1
        adContainerView.layer.borderColor = UIColor.systemGray4.cgColor
        
        // Add placeholder label for ad
        let adLabel = UILabel()
        adLabel.translatesAutoresizingMaskIntoConstraints = false
        adLabel.text = "Advertisement Space"
        adLabel.textAlignment = .center
        adLabel.textColor = .systemGray
        adLabel.font = .systemFont(ofSize: 14)
        
        // Add subviews
        view.addSubview(scrollView)
        view.addSubview(actionButton)
        view.addSubview(adContainerView)
        
        scrollView.addSubview(contentView)
        adContainerView.addSubview(adLabel)
        
        // Center ad label
        NSLayoutConstraint.activate([
            adLabel.centerXAnchor.constraint(equalTo: adContainerView.centerXAnchor),
            adLabel.centerYAnchor.constraint(equalTo: adContainerView.centerYAnchor)
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Ad Container - Fixed at bottom
            adContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 18),
            adContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -18),
            adContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18),
            adContainerView.heightAnchor.constraint(equalToConstant: 240),
            
            // Action Button - Above ad with 20pt padding
            actionButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 18),
            actionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -18),
            actionButton.bottomAnchor.constraint(equalTo: adContainerView.topAnchor, constant: -20),
            actionButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Scroll View - Above button with 18pt padding from top and sides
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 18),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -18),
            scrollView.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -18),
            
            // Content View - Inside scroll view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupActions() {
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc private func buttonTapped() {
        buttonAction?()
    }
    
    // MARK: - Public Methods
    
    /// Add custom content to the scroll view
    func addContentToScrollView(_ view: UIView) {
        contentView.addSubview(view)
    }
    
    /// Set up content with auto layout in the scroll view
    func setupScrollableContent(with views: [UIView]) {
        // Remove existing content
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        var previousView: UIView?
        
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(view)
            
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ])
            
            if let previous = previousView {
                view.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 16).isActive = true
            } else {
                view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true
            }
            
            previousView = view
        }
        
        // Set content view height
        if let lastView = previousView {
            lastView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
        }
    }
    
    /// Replace the ad container with custom ad view
    func setAdView(_ adView: UIView) {
        adContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        adView.translatesAutoresizingMaskIntoConstraints = false
        adContainerView.addSubview(adView)
        
        NSLayoutConstraint.activate([
            adView.topAnchor.constraint(equalTo: adContainerView.topAnchor),
            adView.leadingAnchor.constraint(equalTo: adContainerView.leadingAnchor),
            adView.trailingAnchor.constraint(equalTo: adContainerView.trailingAnchor),
            adView.bottomAnchor.constraint(equalTo: adContainerView.bottomAnchor)
        ])
    }
    
    /// Get reference to scroll view for additional customization
    func getScrollView() -> UIScrollView {
        return scrollView
    }
    
    /// Get reference to content view for direct manipulation
    func getContentView() -> UIView {
        return contentView
    }
}

// MARK: - Usage Example
/*
 class EmailViewController: ReusableViewController {
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
 title = "Email"
 buttonTitle = "Send Email"
 buttonAction = { [weak self] in
 self?.sendEmail()
 }
 
 setupEmailContent()
 }
 
 private func setupEmailContent() {
 let emailAddressField = createTextField(placeholder: "Email address")
 let subjectField = createTextField(placeholder: "Subject")
 let contentTextView = createTextView(placeholder: "Content")
 
 setupScrollableContent(with: [emailAddressField, subjectField, contentTextView])
 }
 
 private func createTextField(placeholder: String) -> UITextField {
 let textField = UITextField()
 textField.placeholder = placeholder
 textField.borderStyle = .roundedRect
 textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
 return textField
 }
 
 private func createTextView(placeholder: String) -> UITextView {
 let textView = UITextView()
 textView.layer.borderColor = UIColor.systemGray4.cgColor
 textView.layer.borderWidth = 1
 textView.layer.cornerRadius = 8
 textView.font = .systemFont(ofSize: 16)
 textView.heightAnchor.constraint(equalToConstant: 200).isActive = true
 return textView
 }
 
 private func sendEmail() {
 // Handle email sending
 print("Sending email...")
 }
 }
 */
