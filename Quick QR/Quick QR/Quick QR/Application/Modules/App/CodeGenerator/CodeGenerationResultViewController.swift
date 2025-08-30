//
//  CodeGenerationResultViewController.swift
//  Quick QR
//
//  Created by Haider Rathore on 30/08/2025.
//

import UIKit

class CodeGenerationResultViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let codeContentView = UIView()
    
    private let qrCodeImageView = UIImageView()
    
    private let barcodeView = UIView()
    private let barcodeContentStackView = UIStackView()
    private let barCodeTypeImageView = UIImageView()
    private let barCodeTypeTitleLabel = UILabel()
    private let barCodeImageView = UIImageView()

    private let titleLabel = UILabel()
    private let descLabel = UILabel()
    
    private let buttonsStackView = UIStackView()
    private let shareButton = AppButtonView()
    private let saveButton = AppButtonView()
    
    private let adView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
        qrCodeImageView.isHidden = true
    }
    
    private func setupUI() {
        codeContentView.translatesAutoresizingMaskIntoConstraints = false
        codeContentView.backgroundColor = .orange

        qrCodeImageView.backgroundColor = .green
        qrCodeImageView.translatesAutoresizingMaskIntoConstraints = false

        barcodeView.backgroundColor = .red
        barcodeView.translatesAutoresizingMaskIntoConstraints = false
        
        barcodeContentStackView.backgroundColor = .yellow
        barcodeContentStackView.axis = .horizontal
        barcodeContentStackView.distribution = .fill
        barcodeContentStackView.alignment = .center
        barcodeContentStackView.spacing = 8
        barcodeContentStackView.translatesAutoresizingMaskIntoConstraints = false

        barCodeTypeImageView.contentMode = .scaleAspectFit
        barCodeTypeImageView.backgroundColor = .blue
        barCodeTypeImageView.translatesAutoresizingMaskIntoConstraints = false

        barCodeTypeTitleLabel.backgroundColor = .magenta
        barCodeTypeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        barCodeImageView.contentMode = .scaleAspectFit
        barCodeImageView.backgroundColor = .green
        barCodeImageView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Wi-Fi Name"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .textPrimary
        
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.text = "PTCL - BB"
        descLabel.textAlignment = .center
        descLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        descLabel.textColor = .appPrimary
        
        buttonsStackView.axis = .horizontal
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.spacing = 8
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        shareButton.configure(with: .primary(title: "Share", image: UIImage(named: "share-icon")))
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        
        saveButton.configure(with: .secondary(title: "Save", image: UIImage(named: "save-icon")))
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        adView.backgroundColor = .gray
        adView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(codeContentView)
        codeContentView.addSubview(qrCodeImageView)
        codeContentView.addSubview(barcodeView)
        barcodeView.addSubview(barcodeContentStackView)
        barcodeView.addSubview(barCodeImageView)
        barcodeContentStackView.addArrangedSubview(barCodeTypeImageView)
        barcodeContentStackView.addArrangedSubview(barCodeTypeTitleLabel)
        view.addSubview(titleLabel)
        view.addSubview(descLabel)
        view.addSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(shareButton)
        buttonsStackView.addArrangedSubview(saveButton)
        view.addSubview(adView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            codeContentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            codeContentView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            codeContentView.heightAnchor.constraint(equalTo: codeContentView.widthAnchor),
            codeContentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            barcodeView.topAnchor.constraint(equalTo: codeContentView.topAnchor, constant: 16),
            barcodeView.leadingAnchor.constraint(equalTo: codeContentView.leadingAnchor, constant: 16),
            barcodeView.trailingAnchor.constraint(equalTo: codeContentView.trailingAnchor, constant: -16),
            barcodeView.bottomAnchor.constraint(equalTo: codeContentView.bottomAnchor, constant: -16),

            barcodeContentStackView.centerXAnchor.constraint(equalTo: barcodeView.centerXAnchor),
            barcodeContentStackView.heightAnchor.constraint(equalToConstant: 40),
            barcodeContentStackView.topAnchor.constraint(equalTo: barcodeView.topAnchor, constant: 8),
            barcodeContentStackView.widthAnchor.constraint(equalTo: barcodeView.widthAnchor, multiplier: 0.6),
            
            barCodeTypeImageView.heightAnchor.constraint(equalToConstant: 36),
            barCodeTypeImageView.widthAnchor.constraint(equalToConstant: 36),
            barCodeTypeTitleLabel.heightAnchor.constraint(equalToConstant: 36),
            
            barCodeImageView.topAnchor.constraint(equalTo: barcodeContentStackView.bottomAnchor, constant: 16),
            barCodeImageView.leadingAnchor.constraint(equalTo: barcodeView.leadingAnchor, constant: 8),
            barCodeImageView.trailingAnchor.constraint(equalTo: barcodeView.trailingAnchor, constant: -8),
            barCodeImageView.bottomAnchor.constraint(equalTo: barcodeView.bottomAnchor, constant: -8),

            qrCodeImageView.topAnchor.constraint(equalTo: codeContentView.topAnchor, constant: 8),
            qrCodeImageView.leadingAnchor.constraint(equalTo: codeContentView.leadingAnchor, constant: 8),
            qrCodeImageView.trailingAnchor.constraint(equalTo: codeContentView.trailingAnchor, constant: -8),
            qrCodeImageView.bottomAnchor.constraint(equalTo: codeContentView.bottomAnchor, constant: -8),
            
            titleLabel.topAnchor.constraint(equalTo: codeContentView.bottomAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: codeContentView.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            descLabel.centerXAnchor.constraint(equalTo: codeContentView.centerXAnchor),
            descLabel.heightAnchor.constraint(equalToConstant: 24),
            
            buttonsStackView.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 28),
            buttonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
            
            saveButton.heightAnchor.constraint(equalTo: buttonsStackView.heightAnchor),
            shareButton.heightAnchor.constraint(equalTo: buttonsStackView.heightAnchor),
            
            adView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            adView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            adView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            adView.heightAnchor.constraint(equalToConstant: 240)
        ])
    }
}
