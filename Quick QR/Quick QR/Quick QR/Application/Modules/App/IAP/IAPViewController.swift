//
//  IAPViewController.swift
//  Quick QR
//
//  Created by Umair Afzal on 29/08/2025.
//

import Foundation
import UIKit
import StoreKit

protocol IAPViewControllerDelegate {
    func performAction()
    func cancelAction()
}

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
            case .monthly: return "Loading..."
            case .yearly: return "Loading..."
            }
        }
        
        var monthlyPrice: String? {
            switch self {
            case .monthly: return nil
            case .yearly: return "Loading..."
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
    
    // MARK: - IAP Properties (from AIIAPViewController)
    private var monthlyProduct: SKProduct?
    private var yearlyProduct: SKProduct?
    var delegate: IAPViewControllerDelegate?
    
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
    private let continueButton = GradientButton(type: .system)
    private let termsStackView = UIStackView()
    
    // MARK: - Loading Indicator (from AIIAPViewController)
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupIAP() // Added IAP setup
        localize() // Added localization
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
        
        // Add loading indicator
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
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
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
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
            topImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
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
        subtitleLabel.textColor = .customColor(fromHex: "585B67")
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
        featureStackView.spacing = 8
        featureStackView.distribution = .fillEqually
        
        let featureContainer = UIView()
        featureContainer.translatesAutoresizingMaskIntoConstraints = false
        featureContainer.backgroundColor = UIColor.customColor(fromHex: "EFF6FF")
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
        containerView.clipsToBounds = false
        
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
        
        // Add subscription info label
        let subscriptionInfoLabel = UILabel()
        subscriptionInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        subscriptionInfoLabel.text = "Once you subscribe, your plan will automatically renew unless you choose to cancel."
        subscriptionInfoLabel.font = UIFont.systemFont(ofSize: 12)
        subscriptionInfoLabel.textColor = .gray
        subscriptionInfoLabel.textAlignment = .center
        subscriptionInfoLabel.numberOfLines = 0
        scrollView.addSubview(subscriptionInfoLabel)
        
        NSLayoutConstraint.activate([
            subscriptionInfoLabel.topAnchor.constraint(equalTo: plansStackView.bottomAnchor, constant: 16),
            subscriptionInfoLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            subscriptionInfoLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            subscriptionInfoLabel.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor, constant: -24)
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
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.gray.withAlphaComponent(0.35).cgColor
        containerView.backgroundColor = .systemGray6
        
        // Create title label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = plan.title
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .black
        
        // Create price label
        let priceLabel = UILabel()
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.text = plan.price
        priceLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        priceLabel.textColor = .black
        priceLabel.textAlignment = .right
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(priceLabel)
        
        var constraints = [
            containerView.heightAnchor.constraint(equalToConstant: 80)
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
            containerView.bringSubviewToFront(tagLabel)
            
            constraints.append(contentsOf: [
                tagLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: -10),
                tagLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
                tagLabel.widthAnchor.constraint(equalToConstant: plan == .monthly ? 140 : 80),
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
        
        // Continue button
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.setBoldTitle("Continue")
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        
        // Terms and privacy
        let termsButton = UIButton(type: .system)
        termsButton.translatesAutoresizingMaskIntoConstraints = false
        termsButton.setTitle("Terms of Service", for: .normal)
        termsButton.setTitleColor(.black, for: .normal)
        termsButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        termsButton.addTarget(self, action: #selector(termsButtonTapped), for: .touchUpInside)
        
        let privacyButton = UIButton(type: .system)
        privacyButton.translatesAutoresizingMaskIntoConstraints = false
        privacyButton.setTitle("Privacy Policy", for: .normal)
        privacyButton.setTitleColor(.black, for: .normal)
        privacyButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        privacyButton.addTarget(self, action: #selector(privacyButtonTapped), for: .touchUpInside)
        
        let separatorLabel = UILabel()
        separatorLabel.translatesAutoresizingMaskIntoConstraints = false
        separatorLabel.text = "|"
        separatorLabel.font = UIFont.systemFont(ofSize: 12)
        separatorLabel.textColor = .black
        
        termsStackView.translatesAutoresizingMaskIntoConstraints = false
        termsStackView.axis = .horizontal
        termsStackView.spacing = 12
        termsStackView.alignment = .center
        termsStackView.distribution = .equalSpacing
        
        termsStackView.addArrangedSubview(termsButton)
        termsStackView.addArrangedSubview(separatorLabel)
        termsStackView.addArrangedSubview(privacyButton)
        
        bottomContainer.addSubview(continueButton)
        bottomContainer.addSubview(termsStackView)
        
        NSLayoutConstraint.activate([
            bottomContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomContainer.topAnchor),
            
            continueButton.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: 16),
            continueButton.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: 65),
            continueButton.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -65),
            continueButton.heightAnchor.constraint(equalToConstant: 60),
        
            termsStackView.topAnchor.constraint(equalTo: continueButton.bottomAnchor, constant: 16),
            termsStackView.centerXAnchor.constraint(equalTo: bottomContainer.centerXAnchor),
            termsStackView.bottomAnchor.constraint(equalTo: bottomContainer.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - IAP Setup Methods (from AIIAPViewController)
    private func setupIAP() {
        loadingIndicator.startAnimating()
        IAPManager.shared.fetchSubscriptions()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleProductsFetched),
                                               name: NSNotification.Name("ProductsFetched"),
                                               object: nil)
    }
    
    private func localize() {
        // Add your localization strings here if needed
        titleLabel.text = "Upgrade to Pro"
    }
    
    @objc private func handleProductsFetched() {
        let products = IAPManager.shared.getSubscriptions()
        
        monthlyProduct = products.first { $0.productIdentifier == SubscriptionID.monthly.rawValue }
        yearlyProduct = products.first { $0.productIdentifier == SubscriptionID.yearly.rawValue }
        
        updatePlanPrices()
        loadingIndicator.stopAnimating()
    }
    
    private func updatePlanPrices() {
        if let monthlyProduct = monthlyProduct {
            let price = IAPManager.shared.getFormattedPrice(for: monthlyProduct)
            updatePlanView(monthlyPlanView, with: price.formatted, monthlyPrice: nil)
        }
        
        if let yearlyProduct = yearlyProduct {
            let price = IAPManager.shared.getFormattedPrice(for: yearlyProduct)
            let monthlyEquivalent = calculateMonthlyEquivalent(for: yearlyProduct)
            updatePlanView(yearlyPlanView, with: price.formatted, monthlyPrice: monthlyEquivalent)
        }
    }
    
    private func calculateMonthlyEquivalent(for product: SKProduct) -> String {
        let yearlyPrice = product.price.doubleValue
        let monthlyEquivalent = yearlyPrice / 12.0
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        
        return formatter.string(from: NSNumber(value: monthlyEquivalent)) ?? "Loading..."
    }
    
    private func updatePlanView(_ planView: UIView, with price: String, monthlyPrice: String?) {
        for subview in planView.subviews {
            if let label = subview as? UILabel {
                // Update main price label
//                if label.font.pointSize == 20 && label.font.weight == .bold {
//                    label.text = price
//                }
//                // Update monthly equivalent price if it exists
//                else if monthlyPrice != nil && label.font.pointSize == 16 && label.font.weight == .medium {
//                    label.text = monthlyPrice
//                }
            }
        }
    }
    
    private func updatePlanSelection() {
        if selectedPlan == .monthly {
            // Monthly plan selected
            monthlyPlanView.layer.shadowColor = UIColor.appPrimary.cgColor
            monthlyPlanView.layer.shadowOffset = CGSize(width: 0, height: 4)
            monthlyPlanView.layer.shadowRadius = 8
            monthlyPlanView.layer.shadowOpacity = 0.5
            monthlyPlanView.layer.masksToBounds = false
            
            monthlyPlanView.backgroundColor = UIColor.appPrimary
            monthlyPlanView.layer.borderColor = UIColor.white.cgColor   // ✅ White border
            
            for subview in monthlyPlanView.subviews {
                if let label = subview as? UILabel, label.text != "Recommended" {
                    label.textColor = .white
                }
            }
            
            yearlyPlanView.layer.shadowOpacity = 0
            yearlyPlanView.backgroundColor = .systemGray6
            yearlyPlanView.layer.borderColor = UIColor.gray.withAlphaComponent(0.35).cgColor   // ✅ Gray border
            
            for subview in yearlyPlanView.subviews {
                if let label = subview as? UILabel, label.text != "Popular" {
                    label.textColor = .black
                }
            }
            
        } else {
            // Yearly plan selected
            yearlyPlanView.layer.shadowColor = UIColor.appPrimary.cgColor
            yearlyPlanView.layer.shadowOffset = CGSize(width: 0, height: 4)
            yearlyPlanView.layer.shadowRadius = 8
            yearlyPlanView.layer.shadowOpacity = 0.5
            yearlyPlanView.layer.masksToBounds = false
            
            yearlyPlanView.backgroundColor = UIColor.appPrimary
            yearlyPlanView.layer.borderColor = UIColor.white.cgColor   // ✅ White border
            
            for subview in yearlyPlanView.subviews {
                if let label = subview as? UILabel, label.text != "Popular" {
                    label.textColor = .white
                }
            }
            
            monthlyPlanView.layer.shadowOpacity = 0
            monthlyPlanView.backgroundColor = .systemGray6
            monthlyPlanView.layer.borderColor = UIColor.gray.withAlphaComponent(0.35).cgColor   // ✅ Gray border
            
            for subview in monthlyPlanView.subviews  {
                if let label = subview as? UILabel, label.text != "Recommended" {
                    label.textColor = .black
                }
            }
        }
    }

    
    private func handleSuccessfulPurchase(message: String) {
        UserDefaults.standard.set(true, forKey: "isSubscribed")
        delegate?.performAction()
        showAlert(title: "Success", message: message) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        delegate?.cancelAction()
        dismiss(animated: true)
    }
    
    @objc private func planViewTapped(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view, let plan = SubscriptionPlan(rawValue: view.tag) else { return }
        selectedPlan = plan
        updatePlanSelection()
    }
    
    @objc private func continueButtonTapped() {
        guard let selectedProduct = selectedPlan == .monthly ? monthlyProduct : yearlyProduct else {
            showAlert(title: "Error", message: "Unable to load subscription products. Please try again.")
            return
        }
        
        loadingIndicator.startAnimating()
        continueButton.isEnabled = false
        
        IAPManager.shared.subscribe(to: selectedProduct) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                self?.continueButton.isEnabled = true
                
                if success {
                    self?.handleSuccessfulPurchase(message: "Thank you for subscribing!")
                } else {
                    let errorMessage = error ?? "Purchase failed. Please try again."
                    self?.showAlert(title: "Purchase Failed", message: errorMessage)
                }
            }
        }
    }
    
    @objc private func restoreButtonTapped() {
        loadingIndicator.startAnimating()
        
        IAPManager.shared.restoreSubscriptions { [weak self] success, restoredTransactions in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                
                if success {
                    self?.handleSuccessfulPurchase(message: "Purchase was successfully restored")
                } else {
                    self?.showAlert(
                        title: "Restore Failed",
                        message: "No active subscriptions found for this account. Please make sure you're signed in with the correct Apple ID."
                    )
                }
            }
        }
    }
    
    @objc private func termsButtonTapped() {
        // Open terms of service - you can use LinkOpener if available or implement URL opening
        if let url = URL(string: "http://termsofuse.softappstechnology.com") {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func privacyButtonTapped() {
        // Open privacy policy - you can use LinkOpener if available or implement URL opening
        if let url = URL(string: "https://privacy.softappstechnology.com/") {
            UIApplication.shared.open(url)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
