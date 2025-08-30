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
    private let titleLabel = UILabel()
    private let descLabel = UILabel()
    private let buttonsStackView = UIStackView()
    private let shareButton = AppButtonView()
    private let saveButton = AppButtonView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        codeContentView.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        view.addSubview(codeContentView)
        view.addSubview(titleLabel)
        view.addSubview(descLabel)
        view.addSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(shareButton)
        buttonsStackView.addArrangedSubview(saveButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            codeContentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            codeContentView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            codeContentView.heightAnchor.constraint(equalTo: codeContentView.widthAnchor),
            codeContentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
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
        ])
    }
}
