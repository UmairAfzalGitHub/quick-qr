//
//  CustomAlertViewController.swift
//  Photo Recovery
//
//  Created by Umair Afzal on 20/06/2025.
//

import Foundation
import UIKit

enum CustomAlertType: Equatable {
    case info
    case error
    case confirmation
    case success
    case warning
    case premium
    case permission
    case custom(iconName: String, tintColor: UIColor, backgroundColor: UIColor)
    
    var showsCancelButton: Bool {
        switch self {
        case .info, .error, .success:
            return false
        case .confirmation, .warning, .premium, .permission, .custom:
            return true
        }
    }
    
    var iconName: String {
        switch self {
        case .info: return "info.circle"
        case .error: return "exclamationmark.triangle"
        case .confirmation: return "questionmark.circle"
        case .success: return "checkmark.circle"
        case .warning: return "exclamationmark.circle"
        case .premium: return "crown"
        case .permission: return "lock.shield"
        case .custom(let iconName, _, _): return iconName
        }
    }
    
    var tintColor: UIColor {
        switch self {
        case .info: return .systemBlue
        case .error: return .systemRed
        case .confirmation: return .red
        case .success: return .green
        case .warning: return .systemOrange
        case .premium: return .systemYellow
        case .permission: return .systemTeal
        case .custom(_, let tintColor, _): return tintColor
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .info: return .systemBlue.withAlphaComponent(0.1)
        case .error: return .red
        case .confirmation: return .gray
        case .success: return .green
        case .warning: return .systemOrange.withAlphaComponent(0.1)
        case .premium: return .systemYellow.withAlphaComponent(0.1)
        case .permission: return .systemTeal.withAlphaComponent(0.1)
        case .custom(_, _, let backgroundColor): return backgroundColor
        }
    }
}

final class CustomAlertViewController: BaseViewController {

    // MARK: - Properties
    private let alertTitle: String
    private let alertDescription: String
    private let cancelText: String
    private let okText: String
    private let alertType: CustomAlertType
    var onCancel: (() -> Void)?
    var onOkay: (() -> Void)?

    // MARK: - UI Elements
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let alertContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()

    private let cancelButton = UIButton(type: .system)
    private let okButton = UIButton(type: .system)

    private let cancelLabel = UILabel()
    private let okLabel = UILabel()

    // MARK: - Initializer
    init(title: String, description: String, cancelText: String = "Cancel", okText: String = "Okay", alertType: CustomAlertType = .info) {
        self.alertTitle = title
        self.alertDescription = description
        self.cancelText = cancelText
        self.okText = okText
        self.alertType = alertType
        super.init()
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissOnTap()
        setupView()
        setupConstraints()
    }

    // MARK: - Setup
    private func setupView() {
        // Set the view's background to clear to ensure transparency
        view.backgroundColor = .clear
        
        view.addSubview(backgroundView)
        view.addSubview(alertContainer)

        [titleLabel, descriptionLabel, iconImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            alertContainer.addSubview($0)
        }

        // Add buttons and labels to main view (not inside alert)
        [okLabel, okButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Only add cancel button and label if needed for this alert type
        if alertType.showsCancelButton {
            [cancelLabel, cancelButton].forEach {
                view.addSubview($0)
                $0.translatesAutoresizingMaskIntoConstraints = false
            }
        }

        // Configure alert based on type
        configureAlertForType(alertType)
        
        // Title
        titleLabel.text = alertTitle
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center

        // Description
        descriptionLabel.text = alertDescription
        descriptionLabel.textColor = .white
        descriptionLabel.font = UIFont.systemFont(ofSize: 15)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0

        // Cancel Button
        cancelButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        cancelButton.tintColor = .white
        cancelButton.backgroundColor = .systemGray
        cancelButton.layer.cornerRadius = 30
        cancelButton.clipsToBounds = true
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        // OK Button
        okButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        okButton.tintColor = .white
        okButton.backgroundColor = .green
        okButton.layer.cornerRadius = 30
        okButton.clipsToBounds = true
        okButton.addTarget(self, action: #selector(okTapped), for: .touchUpInside)

        // Labels above buttons
        cancelLabel.text = cancelText
        cancelLabel.textColor = .white
        cancelLabel.textAlignment = .center
        cancelLabel.font = UIFont.boldSystemFont(ofSize: 14.0)

        okLabel.text = okText
        okLabel.textColor = .white
        okLabel.textAlignment = .center
        okLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
    }

    private func setupConstraints() {
        var constraints = [
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            alertContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertContainer.widthAnchor.constraint(equalToConstant: 280),
            alertContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),

            iconImageView.topAnchor.constraint(equalTo: alertContainer.topAnchor, constant: 16),
            iconImageView.centerXAnchor.constraint(equalTo: alertContainer.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: alertContainer.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: alertContainer.trailingAnchor, constant: -16),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: alertContainer.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: alertContainer.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: alertContainer.bottomAnchor, constant: -80),
            
            okLabel.bottomAnchor.constraint(equalTo: okButton.topAnchor, constant: -4),
            okLabel.centerXAnchor.constraint(equalTo: okButton.centerXAnchor),
        ]
        
        // Position buttons based on alert type
        if alertType.showsCancelButton {
            // Two buttons - cancel on left, ok on right
            constraints.append(contentsOf: [
                cancelLabel.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -4),
                cancelLabel.centerXAnchor.constraint(equalTo: cancelButton.centerXAnchor),
                
                cancelButton.centerYAnchor.constraint(equalTo: alertContainer.bottomAnchor),
                cancelButton.centerXAnchor.constraint(equalTo: alertContainer.leadingAnchor, constant: 70),
                cancelButton.widthAnchor.constraint(equalToConstant: 60),
                cancelButton.heightAnchor.constraint(equalToConstant: 60),
                
                okButton.centerYAnchor.constraint(equalTo: alertContainer.bottomAnchor),
                okButton.centerXAnchor.constraint(equalTo: alertContainer.trailingAnchor, constant: -70),
                okButton.widthAnchor.constraint(equalToConstant: 60),
                okButton.heightAnchor.constraint(equalToConstant: 60)
            ])
        } else {
            // Single button - centered
            constraints.append(contentsOf: [
                okButton.centerYAnchor.constraint(equalTo: alertContainer.bottomAnchor),
                okButton.centerXAnchor.constraint(equalTo: alertContainer.centerXAnchor),
                okButton.widthAnchor.constraint(equalToConstant: 60),
                okButton.heightAnchor.constraint(equalToConstant: 60)
            ])
        }
        
        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Actions
    @objc private func cancelTapped() {
        dismiss(animated: true, completion: onCancel)
    }

    @objc private func okTapped() {
        dismiss(animated: true, completion: onOkay)
    }
    
    // MARK: - Helper Methods
    private func configureAlertForType(_ type: CustomAlertType) {
        // Set icon image
        iconImageView.image = UIImage(systemName: type.iconName)
        iconImageView.tintColor = type.tintColor
        
        // Set alert container style
        alertContainer.backgroundColor = type.backgroundColor
        alertContainer.layer.cornerRadius = 20.0

        // Set button colors
        okButton.backgroundColor = type.tintColor
        
        // Hide cancel button for certain alert types
        cancelButton.isHidden = !type.showsCancelButton
        cancelLabel.isHidden = !type.showsCancelButton

        // Ensure the background view remains transparent
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    }
}
