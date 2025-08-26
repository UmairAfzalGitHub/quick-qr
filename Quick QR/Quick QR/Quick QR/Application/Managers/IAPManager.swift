//
//  IAPManager.swift
//  PhotoRecovery
//
//  Created by Haider on 20/01/2025.
//

import StoreKit

// Subscription Product IDs
enum SubscriptionID: String {
    case weekly = "com.photo.recovery.weekly"
    case monthly = "com.photo.recovery.monthly"
    
    static var allIdentifiers: [String] {
        return [weekly.rawValue, monthly.rawValue]
    }
}

class IAPManager: NSObject {
    // MARK: - Subscription Status Logic
    private var hasVerifiedReceiptThisLaunch = false
    
    private var _isUserSubscribed: Bool? = nil

    var isUserSubscribed: Bool {
        get {
#if DEBUG
            return false
#else
            if let cached = _isUserSubscribed {
                return cached
            }
            if let cached = UserDefaultManager.shared.getValue(.isPremiumMember(false)) as? Bool {
                _isUserSubscribed = cached
                return cached
            }
            if !hasVerifiedReceiptThisLaunch {
                hasVerifiedReceiptThisLaunch = true
                verifySubscriptionStatusIfNeeded()
            }
            return false
#endif
        }
        set {
            _isUserSubscribed = newValue  // update the in-memory variable
            UserDefaultManager.shared.setValue(.isPremiumMember(newValue))
        }
    }

    /// Triggers async receipt verification and updates UserDefaults
    private func verifySubscriptionStatusIfNeeded() {
        guard let receiptURL = Bundle.main.appStoreReceiptURL,
              let receiptData = try? Data(contentsOf: receiptURL) else {
            UserDefaultManager.shared.setValue(.isPremiumMember(false))
            return
        }
        let receiptString = receiptData.base64EncodedString(options: [])
        verifyReceipt(receiptString: receiptString) { [weak self] isSubscribed in
            UserDefaultManager.shared.setValue(.isPremiumMember(isSubscribed))
            self?.isUserSubscribed = isSubscribed
        }
    }
    
    static let shared = IAPManager()
    var products: [SKProduct] = []
    var purchaseCompletion: ((Bool, String?) -> Void)?
    private var restoreCompletion: ((Bool, [SKPaymentTransaction]?) -> Void)?
    private var restoredTransactions: [SKPaymentTransaction] = []
    
    private var currentProduct: SKProduct?
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    func fetchSubscriptions() {
        let productIDs = Set([
            SubscriptionID.weekly.rawValue,
            SubscriptionID.monthly.rawValue
        ])
        
        print("IAP - Products \(productIDs)")
        let request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()
        print("IAP - Requesting products from App Store...")
    }
    
    func subscribe(to product: SKProduct, completion: @escaping (Bool, String?) -> Void) {
        guard SKPaymentQueue.canMakePayments() else {
            completion(false, "IAP - Subscriptions are not allowed on this device")
            return
        }
        
        currentProduct = product
        purchaseCompletion = completion
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func restoreSubscriptions(completion: @escaping (Bool, [SKPaymentTransaction]?) -> Void) {
        // After restoring, update UserDefaults
        UserDefaultManager.shared.setValue(.isPremiumMember(true))
        isUserSubscribed = true
        self.restoreCompletion = completion
        self.restoredTransactions.removeAll()
        
        // Add transaction observer and start restore
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    // Check subscription status
    func checkSubscriptionStatus(completion: @escaping (Bool) -> Void) {
        guard let receiptURL = Bundle.main.appStoreReceiptURL else {
            isUserSubscribed = false
            completion(false)
            return
        }
        
        do {
            let receiptData = try Data(contentsOf: receiptURL)
            let receiptString = receiptData.base64EncodedString()
            verifyReceipt(receiptString: receiptString, completion: completion)
        } catch {
            isUserSubscribed = false
            completion(false)
        }
    }
    
    /// Verifies the receipt and determines if user is subscribed
    private func verifyReceipt(receiptString: String, completion: @escaping (Bool) -> Void) {
        // Determine the App Store endpoint (use sandbox if in development, production otherwise)
        let isSandbox = Bundle.main.appStoreReceiptURL?.absoluteString.contains("sandboxReceipt") ?? false
        let verifyURL = isSandbox ?
        URL(string: "https://sandbox.itunes.apple.com/verifyReceipt") :
        URL(string: "https://buy.itunes.apple.com/verifyReceipt")
        
        guard let url = verifyURL else {
            isUserSubscribed = false
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let requestContents: [String: Any] = [
            "receipt-data": receiptString,
            "password": "f55293fc159847dc8eccfa360865bd00", // Your shared secret here
            "exclude-old-transactions": true
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestContents)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data,
                  let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let status = jsonResponse["status"] as? Int else {
                DispatchQueue.main.async {
                    self.isUserSubscribed = false
                    completion(false)
                }
                return
            }
            
            // Process the response
            DispatchQueue.main.async {
                if status == 0 { // Valid receipt
                    if let latestReceiptInfo = jsonResponse["latest_receipt_info"] as? [[String: Any]] {
                        // Check if any subscription is still active
                        let now = Date().timeIntervalSince1970 * 1000 // Convert to milliseconds
                        let hasActiveSubscription = latestReceiptInfo.contains { transaction in
                            if let expiresDate = transaction["expires_date_ms"] as? String,
                               let expirationDate = Double(expiresDate) {
                                return now < expirationDate
                            }
                            return false
                        }
                        self.isUserSubscribed = hasActiveSubscription
                        completion(hasActiveSubscription)
                    } else {
                        self.isUserSubscribed = false
                        completion(false)
                    }
                } else {
                    self.isUserSubscribed = false
                    completion(false)
                }
            }
        }
        task.resume()
    }
    
    // Get available subscriptions
    func getSubscriptions() -> [SKProduct] {
        return products
    }
    
    // Get formatted price for a product
    func getFormattedPrice(for product: SKProduct) -> (formatted: String, value: Double) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        
        // Safely unwrap the formatted price string
        let formattedPrice = formatter.string(from: product.price) ?? "$\(product.price)"
        let numericValue = product.price.doubleValue
        
        return (formatted: formattedPrice, value: numericValue)
    }
    
    // Get subscription period
    func getSubscriptionPeriod(for product: SKProduct) -> String {
        guard let subscriptionPeriod = product.subscriptionPeriod else {
            return "Unknown"
        }
        
        switch subscriptionPeriod.unit {
        case .day:
            return "\(subscriptionPeriod.numberOfUnits) days"
        case .week:
            return "\(subscriptionPeriod.numberOfUnits) weeks"
        case .month:
            return "\(subscriptionPeriod.numberOfUnits) months"
        case .year:
            return "\(subscriptionPeriod.numberOfUnits) years"
        @unknown default:
            return "Unknown"
        }
    }
}

// MARK: - SKProductsRequestDelegate
extension IAPManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
        print(response.products)
        if !response.invalidProductIdentifiers.isEmpty {
            print("IAP - Invalid Product IDs: \(response.invalidProductIdentifiers)")
        }
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name("ProductsFetched"), object: nil)
        }
    }
}

// MARK: - SKPaymentTransactionObserver
extension IAPManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { transaction in
            switch transaction.transactionState {
            case .purchased:
                handlePurchased(transaction)
            case .failed:
                handleFailed(transaction)
            case .restored:
                handleRestored(transaction)
            case .deferred:
                print("IAP - Subscription purchase deferred")
            case .purchasing:
                print("IAP - Subscription purchase in progress")
            @unknown default:
                print("IAP - Unknown subscription state")
            }
        }
    }
    
    private func handlePurchased(_ transaction: SKPaymentTransaction) {
        // Save subscription state
        UserDefaultManager.shared.setValue(.isSubscribed(true))
        UserDefaultManager.shared.setValue(.subscriptionPurchaseDate(Date()))
        
        // Update subscription status
        isUserSubscribed = true
        
        SKPaymentQueue.default().finishTransaction(transaction)
        purchaseCompletion?(true, nil)
    }
    
    private func handleFailed(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        purchaseCompletion?(false, transaction.error?.localizedDescription)
    }
    
    private func handleRestored(_ transaction: SKPaymentTransaction) {
        restoredTransactions.append(transaction)
        
        // Verify the receipt for this restored transaction
        validateRestoredTransactions { [weak self] isValid in
            if isValid {
                // Save subscription state as active
                UserDefaultManager.shared.setValue(.isSubscribed(true))
                UserDefaultManager.shared.setValue(.subscriptionPurchaseDate(Date()))
                self?.isUserSubscribed = true
            }
            
            // Finish the transaction
            SKPaymentQueue.default().finishTransaction(transaction)
            self?.purchaseCompletion?(true, nil)
        }
    }
    
    private func validateRestoredTransactions(completion: @escaping (Bool) -> Void) {
        guard let receiptURL = Bundle.main.appStoreReceiptURL else {
            completion(false)
            return
        }
        
        do {
            let receiptData = try Data(contentsOf: receiptURL)
            let receiptString = receiptData.base64EncodedString()
            
            // Verify receipt with Apple's servers
            verifyReceipt(receiptString: receiptString) { isValid in
                completion(isValid)
            }
        } catch {
            completion(false)
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if restoredTransactions.isEmpty {
            // No transactions were restored
            restoreCompletion?(false, nil)
            return
        }
        
        // Verify the receipt one final time to ensure we have an active subscription
        validateRestoredTransactions { [weak self] isValid in
            self?.restoreCompletion?(isValid, self?.restoredTransactions)
            self?.restoredTransactions.removeAll()
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        restoreCompletion?(false, nil)
        restoredTransactions.removeAll()
    }
}
