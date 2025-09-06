//
//  CodeGenerationResultViewController.swift
//  Quick QR
//
//  Created by Haider Rathore on 30/08/2025.
//

import UIKit
import Photos

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
    
    // MARK: - Properties
    
    private var saveAction: (() -> Void)?
    private var shareAction: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appSecondaryBackground
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    private func setupUI() {
        // Configure main container view
        codeContentView.translatesAutoresizingMaskIntoConstraints = false
        codeContentView.backgroundColor = .white
        codeContentView.layer.cornerRadius = 12
        codeContentView.layer.borderWidth = 1
        codeContentView.layer.borderColor = UIColor.systemGray4.cgColor
        
        // Configure QR code image view
        qrCodeImageView.contentMode = .scaleAspectFit
        qrCodeImageView.translatesAutoresizingMaskIntoConstraints = false
        qrCodeImageView.backgroundColor = .white

        barcodeView.backgroundColor = .white
        barcodeView.translatesAutoresizingMaskIntoConstraints = false
        
        barcodeContentStackView.axis = .horizontal
        barcodeContentStackView.distribution = .fill
        barcodeContentStackView.alignment = .center
        barcodeContentStackView.spacing = 8
        barcodeContentStackView.translatesAutoresizingMaskIntoConstraints = false

        barCodeTypeImageView.contentMode = .scaleAspectFit
        barCodeTypeImageView.translatesAutoresizingMaskIntoConstraints = false

        barCodeTypeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        barCodeTypeTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        barCodeImageView.contentMode = .scaleAspectFit
        barCodeImageView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .textPrimary
        
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.textAlignment = .center
        descLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        descLabel.textColor = .appPrimary
        
        buttonsStackView.axis = .horizontal
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.spacing = 8
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        shareButton.configure(with: .primary(title: Strings.Label.share, image: UIImage(systemName: "square.and.arrow.up")))
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        
        saveButton.configure(with: .secondary(title: Strings.Label.save, image: UIImage(systemName: "square.and.arrow.down")))
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        adView.backgroundColor = .gray
        adView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    private func setupConstraints() {
        // Add all views to the hierarchy first
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
        
        // Main container constraints
        NSLayoutConstraint.activate([
            codeContentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            codeContentView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            codeContentView.heightAnchor.constraint(equalTo: codeContentView.widthAnchor),
            codeContentView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // QR code image view constraints
        NSLayoutConstraint.activate([
            qrCodeImageView.topAnchor.constraint(equalTo: codeContentView.topAnchor, constant: 8),
            qrCodeImageView.leadingAnchor.constraint(equalTo: codeContentView.leadingAnchor, constant: 8),
            qrCodeImageView.trailingAnchor.constraint(equalTo: codeContentView.trailingAnchor, constant: -8),
            qrCodeImageView.bottomAnchor.constraint(equalTo: codeContentView.bottomAnchor, constant: -8)
        ])
        
        // Barcode view constraints
        NSLayoutConstraint.activate([
            barcodeView.topAnchor.constraint(equalTo: codeContentView.topAnchor, constant: 16),
            barcodeView.leadingAnchor.constraint(equalTo: codeContentView.leadingAnchor, constant: 16),
            barcodeView.trailingAnchor.constraint(equalTo: codeContentView.trailingAnchor, constant: -16),
            barcodeView.bottomAnchor.constraint(equalTo: codeContentView.bottomAnchor, constant: -16)
        ])
        
        // Barcode content stack view constraints
        NSLayoutConstraint.activate([
            barcodeContentStackView.centerXAnchor.constraint(equalTo: barcodeView.centerXAnchor),
            barcodeContentStackView.heightAnchor.constraint(equalToConstant: 40),
            barcodeContentStackView.topAnchor.constraint(equalTo: barcodeView.topAnchor, constant: 8),
            barcodeContentStackView.widthAnchor.constraint(equalTo: barcodeView.widthAnchor, multiplier: 0.6),
            
            barCodeTypeImageView.heightAnchor.constraint(equalToConstant: 36),
            barCodeTypeImageView.widthAnchor.constraint(equalToConstant: 36),
            barCodeTypeTitleLabel.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        // Barcode image view constraints
        NSLayoutConstraint.activate([
            barCodeImageView.topAnchor.constraint(equalTo: barcodeContentStackView.bottomAnchor, constant: 16),
            barCodeImageView.leadingAnchor.constraint(equalTo: barcodeView.leadingAnchor, constant: 8),
            barCodeImageView.trailingAnchor.constraint(equalTo: barcodeView.trailingAnchor, constant: -8),
            barCodeImageView.bottomAnchor.constraint(equalTo: barcodeView.bottomAnchor, constant: -8)
        ])
        
        // Other UI elements constraints
        NSLayoutConstraint.activate([
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
    
    private func setupActions() {
        let shareTapGesture = UITapGestureRecognizer(target: self, action: #selector(shareButtonTapped))
        let saveTapGesture = UITapGestureRecognizer(target: self, action: #selector(saveButtonTapped))

        shareButton.addGestureRecognizer(shareTapGesture)
        saveButton.addGestureRecognizer(saveTapGesture)
        
        print("[CodeGenerationResultViewController] Set up button actions")
    }
    
    // MARK: - Public Methods
    
    /// Set the QR code image and show QR code view
    func setQRCodeImage(_ image: UIImage) {
        // Set image and show QR code view
        qrCodeImageView.image = image
        qrCodeImageView.isHidden = false
        barcodeView.isHidden = true
        
        // Bring QR code image view to front
        codeContentView.bringSubviewToFront(qrCodeImageView)
    }
    
    /// Set the barcode image and show barcode view
    func setBarCodeImage(_ image: UIImage) {
        // Set image and show barcode view
        barCodeImageView.image = image
        barcodeView.isHidden = false
        qrCodeImageView.isHidden = true
        
        // Bring barcode view to front
        codeContentView.bringSubviewToFront(barcodeView)
    }
    
    /// Set the barcode type icon and title
    func setBarCodeType(icon: UIImage?, title: String) {
        barCodeTypeImageView.image = icon
        barCodeTypeTitleLabel.text = title
    }
    
    /// Set the title and description labels
    func setTitleAndDescription(title: String, description: String) {
        titleLabel.text = title
        descLabel.text = description
    }
    
    /// Set the save button action
    func setSaveAction(_ action: @escaping () -> Void) {
        saveAction = action
    }
    
    /// Set the share button action
    func setShareAction(_ action: @escaping () -> Void) {
        shareAction = action
    }
    
    // MARK: - Actions
    
    @objc private func shareButtonTapped() {
        shareAction?()
    }
    
    @objc private func saveButtonTapped() {
        // Present action sheet for save options
        let alert = UIAlertController(title: Strings.Label.saveCode, message: Strings.Label.chooseWhereToSave, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: Strings.Label.saveToGallery, style: .default, handler: { _ in
            self.saveImageToGallery()
        }))
        alert.addAction(UIAlertAction(title: Strings.Label.saveToFiles, style: .default, handler: { _ in
            self.saveImageToFiles()
        }))
        alert.addAction(UIAlertAction(title: Strings.Label.cancel, style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.saveButton
            popover.sourceRect = self.saveButton.bounds
        }
        present(alert, animated: true)
    }

    private func saveImageToGallery() {
        let image = !qrCodeImageView.isHidden ? qrCodeImageView.image : barCodeImageView.image
        guard let imageToSave = image else {
            let alert = UIAlertController(title: Strings.Label.error, message: Strings.Label.noImageToSave, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Strings.Label.ok, style: .default))
            present(alert, animated: true)
            return
        }
        PhotosManager.shared.save(image: imageToSave) { result in
            switch result {
            case .success:
                let alert = UIAlertController(title: "\(Strings.Label.saved)!", message: Strings.Label.imageSavedToLibrary, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: Strings.Label.ok, style: .default))
                self.present(alert, animated: true)
            case .failure(let error):
                let alert = UIAlertController(title: Strings.Label.error, message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: Strings.Label.ok, style: .default))
                self.present(alert, animated: true)
            }
        }
    }

    private func saveImageToFiles() {
        let image = !qrCodeImageView.isHidden ? qrCodeImageView.image : barCodeImageView.image
        guard let imageToSave = image else {
            let alert = UIAlertController(title: Strings.Label.error, message: Strings.Label.noImageToSave, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Strings.Label.ok, style: .default))
            present(alert, animated: true)
            return
        }
        PhotosManager.shared.saveToFiles(image: imageToSave, presenter: self) { result in
            print(result)
        }
    }
}
