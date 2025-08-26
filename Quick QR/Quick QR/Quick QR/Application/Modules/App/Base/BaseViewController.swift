//
//  BaseViewController.swift
//  Photo Recovery
//
//  Created by Umair Afzal on 07/03/2025.
//

import Foundation
import UIKit
import IOS_Helpers
import GoogleMobileAds

enum CellCorner {
    case bottom
    case all
}

class BaseViewController: UIViewController, IAPViewControllerDelegate {

    private var loaderVC: LoaderViewController?
    private var bannerAdId: AdMobId?
    var iapVC: UIViewController?
    
    let customNavigationBar: AppNavigationBar = {
        let navigationBar = AppNavigationBar()
        navigationBar.backgroundColor = .green
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        return navigationBar
    }()
    
    var bannerAdView: BannerView? {
        didSet {
            if let AdId = bannerAdId, !IAPManager.shared.isUserSubscribed {
                AdManager.shared.loadbannerAd(adId: AdId, bannerView: bannerAdView, root: self)
            }
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        style()
        view.backgroundColor = .appPrimaryBackground
        setupNavigationBarAppearance()
        setupStandardBackButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("✅✅ viewWillAppear: \(String(describing: self))✅✅")
        //AdManager.shared.loadbannerAd(bannerView: bannerAdView, root: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("✅✅ viewWillDisappear: \(String(describing: self))✅✅")
    }
    
    deinit {
        print("DE-INIT: \(self)")
    }
    
    func style() {
        
    }
    
    func setupBanner(adId: AdMobId) {
        bannerAdId = adId
    }
    
    func setup() {
//        view.addSubview(customNavigationBar)
//        let navigationBarHeight: CGFloat = UIDevice().isSmallerDevice() ? 70 : 100
//        NSLayoutConstraint.activate([
//            customNavigationBar.topAnchor.constraint(equalTo: view.topAnchor),
//            customNavigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            customNavigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            customNavigationBar.heightAnchor.constraint(equalToConstant: navigationBarHeight)
//        ])
    }
    
    func showIAP() {
        let iapVarientA = IAPViewController()
        iapVarientA.delegate = self
        iapVC = iapVarientA

        iapVC?.modalPresentationStyle = .fullScreen
        iapVC?.modalTransitionStyle = .coverVertical
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.present(self.iapVC ?? UIViewController(), animated: true, completion: nil)
        })
    }
    
    func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground() // Ensures no transparency issues
        appearance.backgroundColor = UIColor.appSecondaryBackground // Change to your desired color
        appearance.titleTextAttributes = [.foregroundColor: UIColor.textPrimary] // Set title color
        
        // Configure back button appearance in the appearance object
        appearance.setBackIndicatorImage(UIImage(systemName: "chevron.left"), transitionMaskImage: UIImage(systemName: "chevron.left"))
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        // Set tint color for all navigation bar items
        navigationController?.navigationBar.tintColor = .black
    }
    
    func hideCustomNavigationBar() {
        customNavigationBar.isHidden = true
    }
    
    func cellsForRounding(contentView: UIView,
                          customSeperator: UIView? = nil,
                          indexPath: IndexPath,
                          tableView: UITableView,
                          corner: CellCorner) {
        
                
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        switch corner {
        case .bottom:
            if isLast {
                contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                customSeperator?.isHidden = true
                contentView.layer.shadowColor = UIColor.black.cgColor
                contentView.layer.shadowOpacity = 1
                contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
                contentView.layer.shadowRadius = 8
                
            } else {
                contentView.layer.cornerRadius = 0
                contentView.layer.maskedCorners = []
                contentView.layer.shadowOpacity = 0
                contentView.layer.masksToBounds = true
            }
        case .all:
            if isFirst || isLast {
                if isFirst {
                    contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                }
                if isLast {
                    contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                    customSeperator?.isHidden = true
                    contentView.layer.shadowColor = UIColor.black.cgColor
                    contentView.layer.shadowOpacity = 1
                    contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
                    contentView.layer.shadowRadius = 8
                }
            } else {
                contentView.layer.cornerRadius = 0
                contentView.layer.maskedCorners = []
                contentView.layer.shadowOpacity = 0
                contentView.layer.masksToBounds = true
            }
        }
    }

    func addLeftNexusView() {
        let imageView = UIImageView(image: UIImage(named: "navBar-vpn"))
        imageView.contentMode = .scaleAspectFit
        customNavigationBar.setLeftCustomView(imageView)
    }
    
    func addRightPremiumView() {
        let imageView = UIImageView(image: UIImage(named: "crown"))
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapMembership))
        imageView.addGestureRecognizer(tapGesture)
        customNavigationBar.setRightCustomView(imageView)
    }
    
    func addRightSearchView() {
        let imageView = UIImageView(image: UIImage(named: "search"))
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSearch))
        imageView.addGestureRecognizer(tapGesture)
        customNavigationBar.setRightCustomView(imageView)
    }
    
    func addBackButton() {
        let imageView = UIImageView(image: UIImage(named: "back-arrow"))
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackButton))
        imageView.addGestureRecognizer(tapGesture)
        customNavigationBar.setLeftCustomView(imageView)
    }
    
    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showCustomAlert(title: String = "Success", message: String, alertType: CustomAlertType = .success, completion: (() -> Void)? = nil) {
        var titleString = title
        if alertType == .error {
            titleString = "Error"
        }
        let alert = CustomAlertViewController(title: titleString,
                                             description: message,
                                             okText: "Okay",
                                              alertType: alertType)
        alert.onOkay = completion
        present(alert, animated: true)
    }
    
    /// Sets up a standard back button with just an arrow icon
    func setupStandardBackButton() {
        // Only set up back button if this is not the root view controller
        if let navigationController = navigationController, navigationController.viewControllers.count > 1 {
            // Hide the default back button
            navigationItem.hidesBackButton = true
            
            // Create a standard back button with just the arrow
            let backButton = UIBarButtonItem(
                image: UIImage(systemName: "chevron.left"),
                style: .plain,
                target: self,
                action: #selector(didTapBackButton)
            )
            backButton.tintColor = .white
            
            // Remove any text from the back button
            navigationItem.backButtonTitle = ""
            
            // Set as left bar button item
            navigationItem.leftBarButtonItem = backButton
        }
    }
    
    @objc func didTapMembership() {
        
    }
    
    @objc func didTapSearch() {
        
    }

    func openWebURL(_ urlString: String) {
        guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
            print("Invalid URL")
            return
        }

        UIApplication.shared.open(url, options: [:]) { success in
            if success {
                print("URL successfully opened")
            } else {
                print("Failed to open URL")
            }
        }
    }
    
    func createCustomStackViewForNavigationBar(image: UIImage?, tint: UIColor? = nil, action: Selector) -> UIStackView {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true

        if let tint {
            imageView.tintColor = tint
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        imageView.addGestureRecognizer(tapGesture)

        let stackView = UIStackView(arrangedSubviews: [imageView])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }

    func showLoader(duration: TimeInterval = 1.0, completion: @escaping () -> Void) {
        let loader = LoaderViewController()
        loader.modalPresentationStyle = .overFullScreen
        loader.modalTransitionStyle = .crossDissolve
        self.loaderVC = loader  // Keep a strong reference
        self.topMostViewController().present(loader, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
                self?.loaderVC?.dismiss(animated: true) {
                    self?.loaderVC = nil
                    completion()
                }
            }
        }
    }
    
    /// Shows a loader with manual control for hiding it
    /// - Parameters:
    ///   - animation: The name of the animation to show
    ///   - completion: Completion handler called after the loader is presented
    func showLoaderWithManualDismissal(animation: String, completion: @escaping () -> Void) {
        let loader = LoaderViewController()
        loader.animationName = animation
        loader.modalPresentationStyle = .overFullScreen
        loader.modalTransitionStyle = .crossDissolve
        self.loaderVC = loader  // Keep a strong reference
        self.topMostViewController().present(loader, animated: true) {
            completion()
        }
    }
    
    /// Hides the currently displayed loader
    /// - Parameter completion: Completion handler called after the loader is dismissed
    func hideLoader(completion: (() -> Void)? = nil) {
        guard let loaderVC = self.loaderVC else {
            completion?()
            return
        }
        
        loaderVC.dismiss(animated: true) {
            self.loaderVC = nil
            completion?()
        }
    }
    
    func showToast(message: String, duration: TimeInterval = 2.0) {
        guard let window = UIApplication.shared.sceneWindow else { return }

        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textAlignment = .center
        toastLabel.backgroundColor = UIColor.appGreenMedium
        toastLabel.textColor = .white
        toastLabel.font = UIFont.systemFont(ofSize: 17)
        toastLabel.alpha = 0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        let textSize = toastLabel.intrinsicContentSize
        let padding: CGFloat = 16
        toastLabel.frame = CGRect(
            x: (window.frame.width - textSize.width - padding) / 2,
            y: window.frame.height - 100,
            width: textSize.width + padding,
            height: textSize.height + padding / 2
        )

        window.addSubview(toastLabel)

        UIView.animate(withDuration: 0.5, animations: {
            toastLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
    
    //MARK: - IAPViewControllerDelegate
    func performAction() {
        print("Perform IAP Action")
    }
}
