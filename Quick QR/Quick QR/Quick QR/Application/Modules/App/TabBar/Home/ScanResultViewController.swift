//
//  ScanResultViewController.swift
//  Quick QR
//
//  Created by Haider Rathore on 02/09/2025.
//

import UIKit

final class ScanResultViewController: UIViewController {
    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    private let topCardView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 12
        v.layer.masksToBounds = true
        return v
    }()
    
    private let titleStack = UIStackView()
    private let iconContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.appPrimary
        v.layer.cornerRadius = 18
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private let typeIconView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "wifi-icon")?.withRenderingMode(.alwaysTemplate).withTintColor(.white))
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    private let typeTitleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Wi‑Fi"
        lb.font = .systemFont(ofSize: 16, weight: .semibold)
        lb.textColor = .textPrimary
        return lb
    }()
    
    private let qrImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "qr-temp-icon"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let actionsStack = UIStackView()
    
    // Bottom information card
    private let infoCardView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 12
        v.layer.masksToBounds = true
        return v
    }()
    private let rowsStack = ScrollableStackView()
    
    // Ad view placeholder
    private let adContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.4)
        v.layer.cornerRadius = 12
        v.layer.masksToBounds = true
        return v
    }()
    private let adLabel: UILabel = {
        let lb = UILabel()
        lb.text = "AD"
        lb.font = .systemFont(ofSize: 12, weight: .bold)
        lb.textColor = .secondaryLabel
        return lb
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appSecondaryBackground
        setupLayout()
        setupTopCard()
        setupInfoCard()
        setupActions()
        populateDummyRows()
    }
    
    // MARK: - Layout
    private func setupLayout() {
        // Scroll container
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill
        contentStack.distribution = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        // Add Ad container outside the scroll view
        adContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(adContainer)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            // Place scrollView above the adContainer
            scrollView.bottomAnchor.constraint(equalTo: adContainer.topAnchor),
            
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
        
        // Add arranged sections (adContainer removed from stack)
        contentStack.addArrangedSubview(topCardView)
        contentStack.addArrangedSubview(infoCardView)
        contentStack.setCustomSpacing(12, after: infoCardView)
        
        // Constrain adContainer to safe area at the bottom
        NSLayoutConstraint.activate([
            adContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            adContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            adContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            adContainer.heightAnchor.constraint(equalToConstant: 240)
        ])
    }
    
    private func setupTopCard() {
        // Title row
        titleStack.axis = .horizontal
        titleStack.alignment = .center
        titleStack.spacing = 10
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        
        iconContainer.addSubview(typeIconView)
        NSLayoutConstraint.activate([
            iconContainer.widthAnchor.constraint(equalToConstant: 36),
            iconContainer.heightAnchor.constraint(equalToConstant: 36),
            typeIconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            typeIconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            typeIconView.widthAnchor.constraint(equalToConstant: 22),
            typeIconView.heightAnchor.constraint(equalToConstant: 22)
        ])
        titleStack.addArrangedSubview(iconContainer)
        titleStack.addArrangedSubview(typeTitleLabel)
        
        // Actions stack
        actionsStack.axis = .horizontal
        actionsStack.alignment = .fill
        actionsStack.distribution = .fillEqually
        actionsStack.spacing = 46
        actionsStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout inside top card
        let inner = UIStackView(arrangedSubviews: [titleStack, qrImageView, actionsStack])
        inner.axis = .vertical
        inner.alignment = .center
        inner.spacing = 8
        inner.translatesAutoresizingMaskIntoConstraints = false
        
        topCardView.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.leadingAnchor.constraint(equalTo: topCardView.leadingAnchor, constant: 8),
            inner.trailingAnchor.constraint(equalTo: topCardView.trailingAnchor, constant: -8),
            inner.topAnchor.constraint(equalTo: topCardView.topAnchor, constant: 22),
            inner.bottomAnchor.constraint(equalTo: topCardView.bottomAnchor, constant: -16),
            qrImageView.widthAnchor.constraint(equalTo: inner.widthAnchor, multiplier: 0.4),
            qrImageView.heightAnchor.constraint(equalTo: qrImageView.widthAnchor)
        ])
    }
    
    private func setupActions() {
        // Create 3 action items (Connect, Download, Share)
        let connect = makeAction(icon: UIImage(named: "wifi-icon")?.withRenderingMode(.alwaysTemplate), title: "Connect")
        let download = makeAction(icon: UIImage(named: "download-result-icon"), title: "Download")
        let share = makeAction(icon: UIImage(named: "share-result-icon"), title: "Share")
        
        actionsStack.addArrangedSubview(connect)
        actionsStack.addArrangedSubview(download)
        actionsStack.addArrangedSubview(share)
    }
    
    private func setupInfoCard() {
        rowsStack.axis = .vertical
        rowsStack.spacing = 12
        rowsStack.disableIntrinsicContentSizeScrolling = true
        rowsStack.translatesAutoresizingMaskIntoConstraints = false
        infoCardView.addSubview(rowsStack)
        NSLayoutConstraint.activate([
            rowsStack.leadingAnchor.constraint(equalTo: infoCardView.leadingAnchor, constant: 16),
            rowsStack.trailingAnchor.constraint(equalTo: infoCardView.trailingAnchor, constant: -16),
            rowsStack.topAnchor.constraint(equalTo: infoCardView.topAnchor, constant: 16),
            rowsStack.bottomAnchor.constraint(equalTo: infoCardView.bottomAnchor, constant: -16),
            rowsStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
        
        // AD badge inside adContainer
        adLabel.translatesAutoresizingMaskIntoConstraints = false
        adContainer.addSubview(adLabel)
        NSLayoutConstraint.activate([
            adLabel.leadingAnchor.constraint(equalTo: adContainer.leadingAnchor, constant: 8),
            adLabel.topAnchor.constraint(equalTo: adContainer.topAnchor, constant: 8)
        ])
    }
    
    // MARK: - Builders
    private func makeAction(icon: UIImage?, title: String) -> UIView {
        let v = UIStackView()
        v.axis = .vertical
        v.backgroundColor = .clear
        v.alignment = .center
        v.spacing = 6
        
        let iv = UIImageView(image: icon)
        iv.tintColor = .appPrimary
        iv.contentMode = .scaleAspectFit
        iv.setContentHuggingPriority(.required, for: .vertical)
        iv.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iv.widthAnchor.constraint(equalToConstant: 32),
            iv.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        let lb = UILabel()
        lb.text = title
        lb.font = .systemFont(ofSize: 16, weight: .semibold)
        lb.textColor = .textPrimary
        
        v.addArrangedSubview(iv)
        v.addArrangedSubview(lb)
        return v
    }
    
    /// Builds one info row view and returns it. Use to repeat rows.
    /// - Parameters:
    ///   - title: Left label text
    ///   - value: Right label text
    ///   - showsButton: Optional trailing button (e.g., copy)
    private func makeInfoRow(title: String, value: String, showsButton: Bool = false, buttonImage: UIImage? = UIImage(systemName: "doc.on.doc")) -> UIView {
        let container = UIView()
        container.layer.cornerRadius = 12
        
        let h = UIStackView()
        h.axis = .horizontal
        h.alignment = .leading
        h.distribution = .fillProportionally
        h.spacing = 8
        h.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        titleLabel.textColor = .textSecondary
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        valueLabel.textColor = .textPrimary
        valueLabel.textAlignment = .left
        
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        h.addArrangedSubview(titleLabel)
        h.addArrangedSubview(spacer)
        h.addArrangedSubview(valueLabel)
        
        let btn = UIButton(type: .system)
        if showsButton {
            btn.setImage(buttonImage, for: .normal)
            btn.tintColor = .appPrimary
            btn.setContentHuggingPriority(.required, for: .horizontal)
            h.addArrangedSubview(btn)
        }
        
        container.addSubview(h)
        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(equalToConstant: 130),
            btn.widthAnchor.constraint(equalToConstant: 40),
            h.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            h.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            h.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            h.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
        return container
    }
    
    // MARK: - Demo
    private func populateDummyRows() {
        let rows: [(String, String, Bool)] = [
            ("Network name:", "PTCL-BB", false),
            ("Security type:", "WPA", false),
            ("Password:", "123654789", true)
        ]
        rows.forEach { title, value, copy in
            rowsStack.addArrangedSubview(makeInfoRow(title: title, value: value, showsButton: copy))
        }
    }
}
