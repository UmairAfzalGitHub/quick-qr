//
//  IAPViewController.swift
//  GhostVPN
//
//  Created by Haider on 11/11/2024.
//

import UIKit
import Lottie
import StoreKit
import IOS_Helpers
import FirebaseAnalytics

protocol IAPViewControllerDelegate {
    func performAction()
}

class IAPViewController: BaseViewController, SubscriptionOptionDelegate {
    private let weeklyOption = SubscriptionOptionView()
    private let monthlyOption = SubscriptionOptionView()
    
    private var weeklyProduct: SKProduct?
    private var monthlyProduct: SKProduct?
    
    var delegate: IAPViewControllerDelegate?
    
    private lazy var subscriptionOptions: [SubscriptionOptionView] = [
        weeklyOption, monthlyOption
    ]
//    @IBOutlet weak var animationView: LottieAnimationView!
    @IBOutlet weak var lottieParentView: UIView!
    @IBOutlet weak var animationView: LottieAnimationView!
    @IBOutlet weak var getPremiumLabel: UILabel!
    @IBOutlet weak var iapBgImage: UIImageView!
    @IBOutlet weak var featuresStackView: UIStackView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var limitedAccessButton: UIButton!
    @IBOutlet weak var restorePurchaseLabel: UILabel!
    @IBOutlet weak var manageSubsLabel: UILabel!
    @IBOutlet weak var privacyLabel: UILabel!
//    @IBOutlet weak var premiumDescTopConstraint: NSLayoutConstraint!
//    @IBOutlet weak var featuresStackTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var continueButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var limitedAccessHeightConstraint: NSLayoutConstraint!
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false // Important for Auto Layout
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    lazy var autoRenewLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Auto renewal, cancel anytime"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.textColor = .textSecondary
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        setup()
        setupIAP()
        Analytics.logEvent("iap_screen_viewed", parameters: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addDiagonalGradient(to: lottieParentView, colors: [.appGreenMedium, .appGreenLight])
    }
    
    override func style() {
        
        getPremiumLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        getPremiumLabel.layer.shadowColor = UIColor.black.cgColor
        getPremiumLabel.layer.shadowOpacity = 0.1
        getPremiumLabel.layer.shadowRadius = 4
//
        continueButton.layer.cornerRadius = 8
        continueButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .black)
        limitedAccessButton.layer.cornerRadius = 8
        continueButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        
//        premiumDescTopConstraint.constant = topConstraint
//        featuresStackTopConstraint.constant = topConstraint

        let continueButtonHeight: CGFloat = UIDevice().isSmallerDevice() ? 45 : 50
        continueButtonHeightConstraint.constant = continueButtonHeight
        
        let limitedButtonHeight: CGFloat = UIDevice().isSmallerDevice() ? 32 : 50
        limitedAccessHeightConstraint.constant = limitedButtonHeight
    }
    
    override func setup() {
        animationView.animationSpeed = 1
        animationView.loopMode = .loop
        animationView.play()
        
        setupSubscriptionOptions()
        
        weeklyOption.setSelected(true)
        subscriptionOptions.forEach { $0.setSelected($0 === weeklyOption) }
        
        let restoreTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapRestorePurchasesLabel))
        restorePurchaseLabel.addGestureRecognizer(restoreTapGesture)
        
        let manageTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapManageSubsLabel))
        manageSubsLabel.addGestureRecognizer(manageTapGesture)
        
        let privacyTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapPrivacyLabel))
        privacyLabel.addGestureRecognizer(privacyTapGesture)
    }
    
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
        
//        // Start loading indicator
//        loadingIndicator.startAnimating()
//        view.addSubview(loadingIndicator)
//        loadingIndicator.center = view.center
//        
//        // Fetch available subscriptions
//        IAPManager.shared.fetchSubscriptions()
//        
//        // Observe for products
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(handleProductsFetched),
//                                               name: NSNotification.Name("ProductsFetched"),
//                                               object: nil)
    }
    
    @objc private func handleProductsFetched() {
        
        let products = IAPManager.shared.products
        print("IAP - Fetched Products:", products.map { $0.productIdentifier })
        
        // Find and store our subscription products
        weeklyProduct = products.first { $0.productIdentifier == SubscriptionID.weekly.rawValue }
        monthlyProduct = products.first { $0.productIdentifier == SubscriptionID.monthly.rawValue }
        
        print("IAP - Weekly Product:", weeklyProduct?.productIdentifier ?? "nil")
        print("IAP - Monthly Product:", monthlyProduct?.productIdentifier ?? "nil")
        
        // Update UI with actual prices
        if let weeklyProduct = weeklyProduct {
            let price = IAPManager.shared.getFormattedPrice(for: weeklyProduct)
            weeklyOption.configure(title: "Weekly Premium", price: "\(price.formatted)/Week")
        }
        
        if let monthlyProduct = monthlyProduct {
            let price = IAPManager.shared.getFormattedPrice(for: monthlyProduct)
            monthlyOption.configure(title: "Monthly Premium", price: "\(price.formatted)/Month")
        }
        
        loadingIndicator.stopAnimating()
    }
    
    @objc func didTapRestorePurchasesLabel() {
        loadingIndicator.startAnimating()
        
        IAPManager.shared.restoreSubscriptions { [weak self] success, restoredTransactions in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                
                if success {
                    // Successfully restored and validated subscription
                    self?.handleSuccessfulPurchase(message: "Purchase restored successfully!")
                } else {
                    self?.showCustomAlert(title: "Restore Failed", message: "No active subscriptions found for this account. Please make sure you're signed in with the correct Apple ID.", alertType: .error)
                }
            }
        }
    }
    
    @objc func didTapManageSubsLabel() {
        if let window = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            Task {
                do {
                    try await AppStore.showManageSubscriptions(in: window)
                }
            }
        }
    }
    
    @objc func didTapPrivacyLabel() {
        if let url = URL(string: "https://doc-hosting.flycricket.io/photo-recovery-videos-recovery-privacy-policy/b1727af7-f37a-4686-b37d-f925a1e26218/privacy") {
            UIApplication.shared.open(url)
        }
    }
    
    func addDiagonalGradient(to view: UIView, colors: [UIColor]) {
        // Remove existing gradient layers if any (prevents layering multiple)
        view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)

        // Ensure gradient follows the view’s rounded corners (if any)
        gradientLayer.cornerRadius = view.layer.cornerRadius
        gradientLayer.masksToBounds = true
        gradientLayer.locations = [0.25, 1]

        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupSubscriptionOptions() {
        view.addSubview(autoRenewLabel)
        view.addSubview(loadingIndicator)

        subscriptionOptions.forEach { option in
            option.delegate = self
            option.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(option)
        }
        let cellHeight = UIDevice().isSmallerDevice() ? 55 : 80
        NSLayoutConstraint.activate([
            featuresStackView.bottomAnchor.constraint(equalTo: weeklyOption.topAnchor, constant: -30),
            
            weeklyOption.bottomAnchor.constraint(equalTo: monthlyOption.topAnchor, constant: -12),
            weeklyOption.leadingAnchor.constraint(equalTo:view.leadingAnchor, constant: 16),
            weeklyOption.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            weeklyOption.heightAnchor.constraint(equalToConstant: CGFloat(cellHeight)),
            
            monthlyOption.bottomAnchor.constraint(equalTo: autoRenewLabel.topAnchor, constant: -6),
            monthlyOption.leadingAnchor.constraint(equalTo:view.leadingAnchor, constant: 16),
            monthlyOption.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            monthlyOption.heightAnchor.constraint(equalToConstant: CGFloat(cellHeight)),
            
            autoRenewLabel.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -40),
            autoRenewLabel.leadingAnchor.constraint(equalTo: monthlyOption.leadingAnchor),
            autoRenewLabel.trailingAnchor.constraint(equalTo: monthlyOption.trailingAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    //MARK: - SubscriptionOptionDelegate
    func subscriptionOptionDidSelect(_ option: SubscriptionOptionView) {
        subscriptionOptions.forEach { $0.setSelected($0 === option) }
        
        let selectedPlan = option === weeklyOption ? "weekly" : "monthly"
        Analytics.logEvent("iap_plan_selected", parameters: [
            "plan": selectedPlan
        ])
    }
    
    @IBAction func didTapContinue(_ sender: Any) {
        guard let selectedProduct = weeklyOption.isSelected ? weeklyProduct :
                                    monthlyOption.isSelected ? monthlyProduct : nil else {
            print("IAP - ❌ Products are nil")
            showCustomAlert(message: "Unable to load subscription products. Please try again.", alertType: .error)
            return
        }
        
        Analytics.logEvent("iap_continue_tapped", parameters: [
            "plan": weeklyOption.isSelected ? "weekly" : "monthly"
        ])
        
        // Show loading
        loadingIndicator.startAnimating()
        continueButton.isEnabled = false
        let plan = selectedProduct.productIdentifier
        let price = selectedProduct.price.stringValue
        let currency = selectedProduct.priceLocale.currencyCode ?? "USD"
        let duration = weeklyOption.isSelected ? "weekly" : "monthly"
        var unit = 0

        if let period = selectedProduct.subscriptionPeriod {
            unit = Int((period as SKProductSubscriptionPeriod).unit.rawValue)
        }

      // Initiate purchase
        IAPManager.shared.subscribe(to: selectedProduct) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                self?.continueButton.isEnabled = true
                
                if success {
                    // Handle successful purchase
                    Analytics.logEvent("iap_trial_started", parameters: [
                        "plan": plan,
                        "price": price,
                        "currency": currency,
                        "duration": duration,
                        "unit": unit
                    ])

                    self?.handleSuccessfulPurchase(message: "Thank you for subscribing!")
                }
            }
        }
    }
    
    @IBAction func didTapLimitedAccess(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Custom Methods
    private func handleSuccessfulPurchase(message: String) {
        // Update UI or navigate to next screen
        UserDefaultManager.shared.setValue(.isSubscribed(true))

        self.delegate?.performAction()
        self.dismiss(animated: true)
        showCustomAlert(message: message)
    }
}
