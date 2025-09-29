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
        case weekly = 0
        case monthly = 1
        
        var title: String {
            switch self {
            case .weekly: return Strings.Label.weekly
            case .monthly: return Strings.Label.monthly
            }
        }
        
        var price: String {
            switch self {
            case .weekly: return "Loading..."
            case .monthly: return "Loading..."
            }
        }
        
        var dailyPrice: String? {
            switch self {
            case .weekly: return "Loading..."
            case .monthly: return nil
            }
        }
        
        var tag: String? {
            switch self {
            case .weekly: return ""
            case .monthly: return Strings.Label.recommended
            }
        }
        
        var perDayText: String? {
            switch self {
            case .weekly: return Strings.Label.perDay
            case .monthly: return nil
            }
        }
        
        var subtitle: String? {
            switch self {
            case .weekly: return Strings.Label.perfectForShortTerm
            case .monthly: return Strings.Label.saveFiftyPercentVs
            }
        }
    }
    
    enum Feature: Int, CaseIterable {
        case membershipBenefits
        case noAds
        case batchScanning
        
        var title: String {
            switch self {
            case .membershipBenefits: return Strings.Label.unlockMoreMembership
            case .noAds: return Strings.Label.noAdsSmoothScanning
            case .batchScanning: return Strings.Label.scanCodesInBatches
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
    private var selectedPlan: SubscriptionPlan = .monthly
    
    // MARK: - IAP Properties
    private var weeklyProduct: SKProduct?
    private var monthlyProduct: SKProduct?
    var delegate: IAPViewControllerDelegate?
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let bottomContainer = UIView()
    
    private let restorePurchasesButton = UIButton()
    
    private let backgroundImageView = UIImageView(image: UIImage(named: "iap-bg-gradient"))
    private let closeButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let topImageView = UIImageView()
    private let mainTitleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let featureStackView = UIStackView()
    
    private var weeklyPlanView = UIView()
    private var monthlyPlanView = UIView()
    private var weeklyTagLabel: UILabel?
    private var monthlyTagLabel: UILabel?
    
    // Store references to price labels for updating
    private var weeklyPriceLabel: UILabel?
    private var monthlyPriceLabel: UILabel?
    private var weeklySubtitleLabel: UILabel?
    private var monthlySubtitleLabel: UILabel?
    private var monthlyWeeklyEquivalentLabel: UILabel?
    
    private let disclaimerLabel = UILabel()
    private let continueButton = GradientButton(type: .system)
    private let termsStackView = UIStackView()
    
    // MARK: - Loading Indicator
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
        setupIAP()
        localize()
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
        
        view.addSubview(restorePurchasesButton)
        restorePurchasesButton.layer.cornerRadius = 8
        restorePurchasesButton.setTitle(Strings.Label.restore, for: .normal)
        restorePurchasesButton.tintColor = .white
        restorePurchasesButton.backgroundColor = .systemBlue.withAlphaComponent(0.3)
        restorePurchasesButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        restorePurchasesButton.translatesAutoresizingMaskIntoConstraints = false
        restorePurchasesButton.addTarget(self, action: #selector(restoreButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            restorePurchasesButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            restorePurchasesButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            restorePurchasesButton.heightAnchor.constraint(equalToConstant: 34),
            restorePurchasesButton.widthAnchor.constraint(equalToConstant: 64)
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
        titleLabel.text = Strings.Label.upgradeToPro
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
        
        var width: CGFloat = UIDevice().isSmallerDevice() ? 140 : 200
        NSLayoutConstraint.activate([
            topImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            topImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            topImageView.widthAnchor.constraint(equalToConstant: width),
            topImageView.heightAnchor.constraint(equalTo: topImageView.widthAnchor)
        ])
    }
    
    private func setupTitles() {
        mainTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        mainTitleLabel.text = Strings.Label.unlockAllFeatures
        mainTitleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        mainTitleLabel.textColor = .appPrimary
        mainTitleLabel.textAlignment = .center
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = Strings.Label.scanAllType
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
        weeklyPlanView = createPlanView(for: .weekly)
        monthlyPlanView = createPlanView(for: .monthly)

        plansStackView.addArrangedSubview(monthlyPlanView)
        plansStackView.addArrangedSubview(weeklyPlanView)

        // Add tag labels as siblings, above their respective plan views
        if let monthlyTag = createTagLabel(for: .monthly) {
            contentView.addSubview(monthlyTag)
            monthlyTagLabel = monthlyTag
            NSLayoutConstraint.activate([
                monthlyTag.topAnchor.constraint(equalTo: monthlyPlanView.topAnchor, constant: -10),
                monthlyTag.trailingAnchor.constraint(equalTo: monthlyPlanView.trailingAnchor, constant: -20),
                monthlyTag.widthAnchor.constraint(equalToConstant: 140),
                monthlyTag.heightAnchor.constraint(equalToConstant: 24)
            ])
        }

        NSLayoutConstraint.activate([
            plansStackView.topAnchor.constraint(equalTo: featureStackView.superview!.bottomAnchor, constant: 24),
            plansStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            plansStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            plansStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -24)
        ])
        
        // Add subscription info label
        let subscriptionInfoLabel = UILabel()
        subscriptionInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        subscriptionInfoLabel.text = Strings.Label.onceYouSubscribe
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
        selectedPlan = .monthly
        updatePlanSelection()
    }
    
    private func createPlanView(for plan: SubscriptionPlan) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 16
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.gray.withAlphaComponent(0.35).cgColor
        containerView.backgroundColor = .systemGray6
        containerView.clipsToBounds = false

        // Left side vertical stack (title + subtitle/additional info)
        let leftStack = UIStackView()
        leftStack.translatesAutoresizingMaskIntoConstraints = false
        leftStack.axis = .vertical
        leftStack.spacing = 4
        leftStack.alignment = .leading
        leftStack.distribution = .fill

        // Title
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = plan.title
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .black

        // Subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        if let subtitle = plan.subtitle {
            subtitleLabel.text = subtitle
        }
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .gray
        subtitleLabel.numberOfLines = 0

        // Store reference to subtitle labels
        if plan == .weekly {
            weeklySubtitleLabel = subtitleLabel
        } else {
            monthlySubtitleLabel = subtitleLabel
        }

        leftStack.addArrangedSubview(titleLabel)
        leftStack.addArrangedSubview(subtitleLabel)

        // Right side vertical stack (price + additional price info if needed)
        let rightStack = UIStackView()
        rightStack.translatesAutoresizingMaskIntoConstraints = false
        rightStack.axis = .vertical
        rightStack.spacing = 2
        rightStack.alignment = .trailing
        rightStack.distribution = .fill

        // Price
        let priceLabel = UILabel()
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.text = plan.price
        priceLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        priceLabel.textColor = .black
        priceLabel.textAlignment = .right

        // Store reference to price labels
        if plan == .weekly {
            weeklyPriceLabel = priceLabel
        } else {
            monthlyPriceLabel = priceLabel
        }

        rightStack.addArrangedSubview(priceLabel)

        // For monthly plan, add weekly equivalent below the price
        if plan == .monthly {
            let weeklyEquivalentLabel = UILabel()
            weeklyEquivalentLabel.translatesAutoresizingMaskIntoConstraints = false
            weeklyEquivalentLabel.text = "Loading..."
            weeklyEquivalentLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            weeklyEquivalentLabel.textColor = .black
            weeklyEquivalentLabel.textAlignment = .right
            weeklyEquivalentLabel.numberOfLines = 0
            monthlyWeeklyEquivalentLabel = weeklyEquivalentLabel
            rightStack.addArrangedSubview(weeklyEquivalentLabel)
        }

        containerView.addSubview(leftStack)
        containerView.addSubview(rightStack)

        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 90),

            leftStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            leftStack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            leftStack.trailingAnchor.constraint(lessThanOrEqualTo: rightStack.leadingAnchor, constant: -12),

            rightStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            rightStack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(planViewTapped(_:)))
        containerView.addGestureRecognizer(tapGesture)
        containerView.tag = plan.rawValue
        containerView.isUserInteractionEnabled = true

        return containerView
    }

    private func createTagLabel(for plan: SubscriptionPlan) -> UILabel? {
        guard let tagText = plan.tag else { return nil }
        let tagLabel = UILabel()
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        tagLabel.text = tagText
        tagLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        tagLabel.textColor = .white
        tagLabel.backgroundColor = .systemGreen
        tagLabel.textAlignment = .center
        tagLabel.layer.cornerRadius = 12
        tagLabel.clipsToBounds = true
        tagLabel.layer.zPosition = 999
        return tagLabel
    }
    
    private func setupBottomContainer() {
        bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.backgroundColor = .systemBackground
        view.addSubview(bottomContainer)
        
        // Continue button
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.setBoldTitle(Strings.Label.continueLabel)
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        
        // Terms and privacy
        let termsButton = UIButton(type: .system)
        termsButton.translatesAutoresizingMaskIntoConstraints = false
        termsButton.setTitle(Strings.Label.termsOfService, for: .normal)
        termsButton.setTitleColor(.black, for: .normal)
        termsButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        termsButton.addTarget(self, action: #selector(termsButtonTapped), for: .touchUpInside)
        
        let privacyButton = UIButton(type: .system)
        privacyButton.translatesAutoresizingMaskIntoConstraints = false
        privacyButton.setTitle(Strings.Label.privacyPolicy, for: .normal)
        privacyButton.setTitleColor(.black, for: .normal)
        privacyButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        privacyButton.addTarget(self, action: #selector(privacyButtonTapped), for: .touchUpInside)
        
        let manageSubscriptionButton = UIButton(type: .system)
        manageSubscriptionButton.translatesAutoresizingMaskIntoConstraints = false
        manageSubscriptionButton.setTitle(Strings.Label.manageSubscription, for: .normal)
        manageSubscriptionButton.setTitleColor(.black, for: .normal)
        manageSubscriptionButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        manageSubscriptionButton.addTarget(self, action: #selector(manageButtonTapped), for: .touchUpInside)
        
        let separatorLabel = UILabel()
        separatorLabel.translatesAutoresizingMaskIntoConstraints = false
        separatorLabel.text = "|"
        separatorLabel.font = UIFont.systemFont(ofSize: 12)
        separatorLabel.textColor = .black
        
        let separatorTwoLabel = UILabel()
        separatorTwoLabel.translatesAutoresizingMaskIntoConstraints = false
        separatorTwoLabel.text = "|"
        separatorTwoLabel.font = UIFont.systemFont(ofSize: 12)
        separatorTwoLabel.textColor = .black
        
        termsStackView.translatesAutoresizingMaskIntoConstraints = false
        termsStackView.axis = .horizontal
        termsStackView.spacing = 12
        termsStackView.alignment = .center
        termsStackView.distribution = .equalSpacing
        
        termsStackView.addArrangedSubview(termsButton)
        termsStackView.addArrangedSubview(separatorLabel)
        termsStackView.addArrangedSubview(manageSubscriptionButton)
        termsStackView.addArrangedSubview(separatorTwoLabel)
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
    
    // MARK: - IAP Setup Methods
    private func setupIAP() {
        if !IAPManager.shared.products.isEmpty {
            handleProductsFetched()
        } else {
            loadingIndicator.startAnimating()
            view.addSubview(loadingIndicator)
            loadingIndicator.center = view.center
            IAPManager.shared.fetchSubscriptions()
            
            // Observe for products
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(handleProductsFetched),
                                                   name: NSNotification.Name("ProductsFetched"),
                                                   object: nil)
        }
    }
    
    private func localize() {
        titleLabel.text = Strings.Label.upgradeToPro
    }
    
    @objc private func handleProductsFetched() {
        let products = IAPManager.shared.products
        
        // Update to match your actual product identifiers
        weeklyProduct = products.first { $0.productIdentifier == SubscriptionID.weekly.rawValue }
        monthlyProduct = products.first { $0.productIdentifier == SubscriptionID.monthly.rawValue }
        
        updatePlanPrices()
        loadingIndicator.stopAnimating()
    }
    
    private func updatePlanPrices() {
        if let weeklyProduct = weeklyProduct {
            let price = IAPManager.shared.getFormattedPrice(for: weeklyProduct)
            weeklyPriceLabel?.text = price.formatted
        }

        if let monthlyProduct = monthlyProduct {
            let price = IAPManager.shared.getFormattedPrice(for: monthlyProduct)
            monthlyPriceLabel?.text = price.formatted

            // Show weekly equivalent for monthly plan
            let weeklyEquivalent = calculateWeeklyEquivalent(for: monthlyProduct)
            monthlyWeeklyEquivalentLabel?.text = weeklyEquivalent
        }
    }
    
    private func calculateWeeklyEquivalent(for product: SKProduct) -> String {
        let monthlyPrice = product.price.doubleValue
        let weeklyEquivalent = monthlyPrice / 4.0 // rough 4 weeks in a month

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale

        if let formattedPrice = formatter.string(from: NSNumber(value: weeklyEquivalent)) {
            return "\(formattedPrice) weekly"
        }
        return "Loading..."
    }
    
    private func updatePlanSelection() {
        // Reset both plans first
        weeklyPlanView.layer.shadowOpacity = 0
        weeklyPlanView.backgroundColor = .systemGray6
        weeklyPlanView.layer.borderColor = UIColor.gray.withAlphaComponent(0.35).cgColor
        
        monthlyPlanView.layer.shadowOpacity = 0
        monthlyPlanView.backgroundColor = .systemGray6
        monthlyPlanView.layer.borderColor = UIColor.gray.withAlphaComponent(0.35).cgColor
        
        // Reset text colors to black for all labels in stacks
        updateStackViewTextColors(in: weeklyPlanView, color: .black)
        updateStackViewTextColors(in: monthlyPlanView, color: .black)
        
        // Apply selection styling
        let selectedView = selectedPlan == .weekly ? weeklyPlanView : monthlyPlanView
        
        selectedView.layer.shadowColor = UIColor.appPrimary.cgColor
        selectedView.layer.shadowOffset = CGSize(width: 0, height: 4)
        selectedView.layer.shadowRadius = 8
        selectedView.layer.shadowOpacity = 0.5
        selectedView.layer.masksToBounds = false
        
        selectedView.backgroundColor = UIColor.appPrimary
        selectedView.layer.borderColor = UIColor.white.cgColor
        
        // Update text colors for selected plan
        updateStackViewTextColors(in: selectedView, color: .white)
    }
    
    private func updateStackViewTextColors(in view: UIView, color: UIColor) {
        for subview in view.subviews {
            if let stackView = subview as? UIStackView {
                updateStackViewTextColors(in: stackView, color: color)
            } else if let label = subview as? UILabel {
                label.textColor = color
            }
        }
    }
    
    private func handleSuccessfulPurchase(message: String) {
        UserDefaults.standard.set(true, forKey: "isSubscribed")
        delegate?.performAction()
        showAlert(title: Strings.Label.success, message: message) {
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
        guard let selectedProduct = selectedPlan == .weekly ? weeklyProduct : monthlyProduct else {
            showAlert(title: Strings.Label.error, message: Strings.Label.unableToLoad)
            return
        }
        
        loadingIndicator.startAnimating()
        continueButton.isEnabled = false
        
        IAPManager.shared.subscribe(to: selectedProduct) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                self?.continueButton.isEnabled = true
                
                if success {
                    self?.handleSuccessfulPurchase(message: Strings.Label.thankyouForSubscribing)
                } else {
                    let errorMessage = error ?? Strings.Label.purchaseFailedTryAgain
                    self?.showAlert(title: Strings.Label.purchaseFailed, message: errorMessage)
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
                    self?.handleSuccessfulPurchase(message: Strings.Label.purchaseSuccessfullyRestored)
                } else {
                    self?.showAlert(
                        title: Strings.Label.restoreFailed,
                        message: Strings.Label.noActiveSubscriptions
                    )
                }
            }
        }
    }
    
    @objc private func termsButtonTapped() {
        if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func privacyButtonTapped() {
        if let url = URL(string: "https://qrcodescanerreader.blogspot.com/2025/09/qr-code-scanner.html") {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func manageButtonTapped() {
        if let window = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            Task {
                do {
                    try await AppStore.showManageSubscriptions(in: window)
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
