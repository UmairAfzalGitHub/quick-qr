//
//  IAPViewController.swift
//  Quick QR
//
//  Created by Umair Afzal on 29/08/2025.
//

import Foundation
import UIKit

class IAPViewController: UIViewController {
    
    // MARK: - Models
    enum SubscriptionPlan: Int, CaseIterable {
        case monthly
        case yearly
        
        var title: String {
            switch self {
            case .monthly: return "Monthly"
            case .yearly: return "Yearly"
            }
        }
        
        var price: String {
            switch self {
            case .monthly: return "RS 600.00"
            case .yearly: return "RS 600.00"
            }
        }
        
        var monthlyPrice: String? {
            switch self {
            case .monthly: return nil
            case .yearly: return "RS 100.00"
            }
        }
        
        var tag: String? {
            switch self {
            case .monthly: return "Recommended"
            case .yearly: return "Popular"
            }
        }
        
        var perMonthText: String? {
            switch self {
            case .monthly: return nil
            case .yearly: return "per month"
            }
        }
    }
    
    enum Feature: Int, CaseIterable {
        case membershipBenefits
        case noAds
        case batchScanning
        
        var title: String {
            switch self {
            case .membershipBenefits: return "Unlock more membership benefits"
            case .noAds: return "No ads, smooth scanning"
            case .batchScanning: return "Scan codes in batches"
            }
        }
        
        var imageName: String {
            switch self {
            case .membershipBenefits: return "crown-iap"
            case .noAds: return "noAds-iap"
            case .batchScanning: return "scanner-iap"
            }
        }
    }
    
    // MARK: - Properties
    private var selectedPlan: SubscriptionPlan = .yearly
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let bottomContainer = UIView()
    
    private let backgroundImageView = UIImageView(image: UIImage(named: "iap-bg-gradient"))
    private let closeButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let topImageView = UIImageView()
    private let mainTitleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let featureStackView = UIStackView()
    
    private var monthlyPlanView = UIView()
    private var yearlyPlanView = UIView()
    
    private let disclaimerLabel = UILabel()
    private let continueButton = UIButton(type: .system)
    private let termsStackView = UIStackView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Setup background image
        setupBackgroundImage()
        
        // Setup scroll view
        setupScrollView()
        
        // Setup header
        setupHeader()
        
        // Setup QR image with crown
        setupQRImage()
        
        // Setup titles
        setupTitles()
        
        // Setup features
        setupFeatures()
        
        // Setup subscription plans
        setupSubscriptionPlans()
        
        // Setup bottom container
        setupBottomContainer()
    }
    
    private func setupBackgroundImage() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.contentMode = .scaleAspectFill
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }
    
    private func setupHeader() {
        // Close button
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .gray
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Upgrade to pro"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textAlignment = .center
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    private func setupQRImage() {
        topImageView.translatesAutoresizingMaskIntoConstraints = false
        topImageView.image = UIImage(named: "top-crown-iap")
        topImageView.contentMode = .scaleAspectFit
        
        contentView.addSubview(topImageView)
        
        NSLayoutConstraint.activate([
            topImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            topImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            topImageView.widthAnchor.constraint(equalToConstant: 200),
            topImageView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupTitles() {
        mainTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        mainTitleLabel.text = "Unlock all features"
        mainTitleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        mainTitleLabel.textColor = .appPrimary
        mainTitleLabel.textAlignment = .center
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Scan all type of QR Codes & bar Codes"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        
        contentView.addSubview(mainTitleLabel)
        contentView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            mainTitleLabel.topAnchor.constraint(equalTo: topImageView.bottomAnchor, constant: 0),
            mainTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: mainTitleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupFeatures() {
        featureStackView.translatesAutoresizingMaskIntoConstraints = false
        featureStackView.axis = .vertical
        featureStackView.spacing = 16
        featureStackView.distribution = .fillEqually
        
        let featureContainer = UIView()
        featureContainer.translatesAutoresizingMaskIntoConstraints = false
        featureContainer.backgroundColor = UIColor.systemGray6
        featureContainer.layer.cornerRadius = 12
        
        contentView.addSubview(featureContainer)
        featureContainer.addSubview(featureStackView)
        
        NSLayoutConstraint.activate([
            featureContainer.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            featureContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            featureContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            featureStackView.topAnchor.constraint(equalTo: featureContainer.topAnchor, constant: 16),
            featureStackView.leadingAnchor.constraint(equalTo: featureContainer.leadingAnchor, constant: 16),
            featureStackView.trailingAnchor.constraint(equalTo: featureContainer.trailingAnchor, constant: -16),
            featureStackView.bottomAnchor.constraint(equalTo: featureContainer.bottomAnchor, constant: -16)
        ])
        
        // Add features
        for feature in Feature.allCases {
            let featureView = createFeatureView(with: feature)
            featureStackView.addArrangedSubview(featureView)
        }
    }
    
    private func createFeatureView(with feature: Feature) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.image = UIImage(named: feature.imageName)
        iconView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = feature.title
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .label
        
        containerView.addSubview(iconView)
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 24),
            
            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        return containerView
    }
    
    private func setupSubscriptionPlans() {
        let plansStackView = UIStackView()
        plansStackView.translatesAutoresizingMaskIntoConstraints = false
        plansStackView.axis = .vertical
        plansStackView.spacing = 16
        plansStackView.distribution = .fillEqually
        contentView.addSubview(plansStackView)
        
        // Create plan views
        monthlyPlanView = createPlanView(for: .monthly)
        yearlyPlanView = createPlanView(for: .yearly)
        
        plansStackView.addArrangedSubview(monthlyPlanView)
        plansStackView.addArrangedSubview(yearlyPlanView)
        
        NSLayoutConstraint.activate([
            plansStackView.topAnchor.constraint(equalTo: featureStackView.superview!.bottomAnchor, constant: 24),
            plansStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            plansStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            plansStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -24)
        ])
        
        // Set initial selection
        selectedPlan = .yearly
        updatePlanSelection()
    }
    
    private func createPlanView(for plan: SubscriptionPlan) -> UIView {
        // Create container view
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 16
        containerView.backgroundColor = .systemGray6
        
        // Create title label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = plan.title
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .black
        
        // Create price label
        let priceLabel = UILabel()
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.text = plan.price
        priceLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        priceLabel.textColor = .black
        priceLabel.textAlignment = .right
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(priceLabel)
        
        var constraints = [
            containerView.heightAnchor.constraint(equalToConstant: 70)
        ]
        
        // Add tag label if available
        if let tagText = plan.tag {
            let tagLabel = UILabel()
            tagLabel.translatesAutoresizingMaskIntoConstraints = false
            tagLabel.text = tagText
            tagLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            tagLabel.textColor = .white
            tagLabel.backgroundColor = plan == .monthly ? .systemGreen : .systemPink
            tagLabel.textAlignment = .center
            tagLabel.layer.cornerRadius = 12
            tagLabel.clipsToBounds = true
            
            containerView.addSubview(tagLabel)
            
            constraints.append(contentsOf: [
                tagLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: -10),
                tagLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
                tagLabel.widthAnchor.constraint(equalToConstant: 80),
                tagLabel.heightAnchor.constraint(equalToConstant: 24)
            ])
        }
        
        // Add per month label if available
        if let perMonthText = plan.perMonthText, let monthlyPrice = plan.monthlyPrice {
            let perMonthLabel = UILabel()
            perMonthLabel.translatesAutoresizingMaskIntoConstraints = false
            perMonthLabel.text = perMonthText
            perMonthLabel.font = UIFont.systemFont(ofSize: 14)
            perMonthLabel.textColor = .black
            
            let monthlyPriceLabel = UILabel()
            monthlyPriceLabel.translatesAutoresizingMaskIntoConstraints = false
            monthlyPriceLabel.text = monthlyPrice
            monthlyPriceLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            monthlyPriceLabel.textColor = .black
            monthlyPriceLabel.textAlignment = .right
            
            containerView.addSubview(perMonthLabel)
            containerView.addSubview(monthlyPriceLabel)
            
            // Adjust container height for the additional content
            constraints.removeFirst() // Remove the original height constraint
            constraints.append(containerView.heightAnchor.constraint(equalToConstant: 90))
        }
        
        // Position the labels properly
        if plan == .yearly {
            // For yearly plan with additional labels
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
                titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
                
                priceLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
                priceLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16)
            ])
            
            // Find the per month labels
            for subview in containerView.subviews {
                if let label = subview as? UILabel {
                    if label.text == "per month" {
                        NSLayoutConstraint.activate([
                            label.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                            label.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2)
                        ])
                    } else if label.text == plan.monthlyPrice {
                        NSLayoutConstraint.activate([
                            label.trailingAnchor.constraint(equalTo: priceLabel.trailingAnchor),
                            label.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 2)
                        ])
                    }
                }
            }
        } else {
            // For monthly plan
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
                titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                
                priceLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
                priceLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
            ])
        }
        
        NSLayoutConstraint.activate(constraints)
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(planViewTapped(_:)))
        containerView.addGestureRecognizer(tapGesture)
        containerView.tag = plan.rawValue
        containerView.isUserInteractionEnabled = true
        
        return containerView
    }
    
    private func setupBottomContainer() {
        bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.backgroundColor = .systemBackground
        view.addSubview(bottomContainer)
        
        // Disclaimer label
        disclaimerLabel.translatesAutoresizingMaskIntoConstraints = false
        disclaimerLabel.text = "Once you subscribe, your plan will automatically renew unless you choose to cancel."
        disclaimerLabel.font = UIFont.systemFont(ofSize: 12)
        disclaimerLabel.textColor = .secondaryLabel
        disclaimerLabel.textAlignment = .center
        disclaimerLabel.numberOfLines = 0
        
        // Continue button
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.setTitle("Continue", for: .normal)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        continueButton.backgroundColor = .systemOrange
        continueButton.layer.cornerRadius = 25
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        
        // Terms and privacy
        let termsButton = UIButton(type: .system)
        termsButton.translatesAutoresizingMaskIntoConstraints = false
        termsButton.setTitle("Terms of Service", for: .normal)
        termsButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        termsButton.addTarget(self, action: #selector(termsButtonTapped), for: .touchUpInside)
        
        let privacyButton = UIButton(type: .system)
        privacyButton.translatesAutoresizingMaskIntoConstraints = false
        privacyButton.setTitle("Privacy Policy", for: .normal)
        privacyButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        privacyButton.addTarget(self, action: #selector(privacyButtonTapped), for: .touchUpInside)
        
        let separatorLabel = UILabel()
        separatorLabel.translatesAutoresizingMaskIntoConstraints = false
        separatorLabel.text = "|"
        separatorLabel.font = UIFont.systemFont(ofSize: 12)
        separatorLabel.textColor = .tertiaryLabel
        
        termsStackView.translatesAutoresizingMaskIntoConstraints = false
        termsStackView.axis = .horizontal
        termsStackView.spacing = 8
        termsStackView.alignment = .center
        termsStackView.distribution = .equalSpacing
        
        termsStackView.addArrangedSubview(termsButton)
        termsStackView.addArrangedSubview(separatorLabel)
        termsStackView.addArrangedSubview(privacyButton)
        
        bottomContainer.addSubview(disclaimerLabel)
        bottomContainer.addSubview(continueButton)
        bottomContainer.addSubview(termsStackView)
        
        NSLayoutConstraint.activate([
            bottomContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomContainer.topAnchor),
            
            disclaimerLabel.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: 8),
            disclaimerLabel.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: 20),
            disclaimerLabel.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -20),
            
            continueButton.topAnchor.constraint(equalTo: disclaimerLabel.bottomAnchor, constant: 16),
            continueButton.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            
            termsStackView.topAnchor.constraint(equalTo: continueButton.bottomAnchor, constant: 16),
            termsStackView.centerXAnchor.constraint(equalTo: bottomContainer.centerXAnchor),
            termsStackView.bottomAnchor.constraint(equalTo: bottomContainer.bottomAnchor, constant: -16)
        ])
    }
    
    private func updatePlanSelection() {
        // Monthly plan styling
        if selectedPlan == .monthly {
            // Apply shadow to monthly plan
            monthlyPlanView.layer.shadowColor = UIColor.appPrimary.cgColor
            monthlyPlanView.layer.shadowOffset = CGSize(width: 0, height: 4)
            monthlyPlanView.layer.shadowRadius = 8
            monthlyPlanView.layer.shadowOpacity = 0.5
            monthlyPlanView.layer.masksToBounds = false
            
            // Update background color
            monthlyPlanView.backgroundColor = UIColor.appPrimary
            
            // Update text colors for selected plan
            for subview in monthlyPlanView.subviews {
                if let label = subview as? UILabel {
                    if label.text == "Recommended" {
                        // Keep tag label styling
                        continue
                    }
                    label.textColor = .white
                }
            }
            
            // Remove shadow from yearly plan
            yearlyPlanView.layer.shadowOpacity = 0
            
            // Update background color
            yearlyPlanView.backgroundColor = .systemGray6
            
            // Reset text colors for non-selected plan
            for subview in yearlyPlanView.subviews {
                if let label = subview as? UILabel {
                    if label.text == "Popular" {
                        // Keep tag label color
                        continue
                    }
                    label.textColor = .black
                }
            }
        } else {
            // Remove shadow from monthly plan
            monthlyPlanView.layer.shadowOpacity = 0
            
            // Update background color
            monthlyPlanView.backgroundColor = .systemGray6
            
            // Reset text colors for non-selected plan
            for subview in monthlyPlanView.subviews {
                if let label = subview as? UILabel {
                    if label.text == "Recommended" {
                        // Keep tag label color
                        continue
                    }
                    label.textColor = .black
                }
            }
            
            // Apply shadow to yearly plan
            yearlyPlanView.layer.shadowColor = UIColor.appPrimary.cgColor
            yearlyPlanView.layer.shadowOffset = CGSize(width: 0, height: 4)
            yearlyPlanView.layer.shadowRadius = 8
            yearlyPlanView.layer.shadowOpacity = 0.5
            yearlyPlanView.layer.masksToBounds = false
            
            // Update background color
            yearlyPlanView.backgroundColor = UIColor.appPrimary
            
            // Update text colors for selected plan
            for subview in yearlyPlanView.subviews {
                if let label = subview as? UILabel {
                    if label.text == "Popular" {
                        // Keep tag label styling
                        continue
                    }
                    label.textColor = .white
                }
            }
        }
    }
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func planViewTapped(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view, let plan = SubscriptionPlan(rawValue: view.tag) else { return }
        selectedPlan = plan
        updatePlanSelection()
    }
    
    @objc private func continueButtonTapped() {
        // Handle purchase
        print("Continue with plan: \(selectedPlan)")
    }
    
    @objc private func termsButtonTapped() {
        // Open terms of service
        print("Terms of Service tapped")
    }
    
    @objc private func privacyButtonTapped() {
        // Open privacy policy
        print("Privacy Policy tapped")
    }
}
