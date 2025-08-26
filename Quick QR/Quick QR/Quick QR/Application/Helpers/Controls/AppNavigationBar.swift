//
//  AppNavigationBat.swift
//  Photo Recovery
//
//  Created by Umair Afzal on 07/03/2025.
//

import Foundation
import UIKit

class AppNavigationBar: UIView {

    // MARK: - UI Elements
    private let leftContainerView = UIView()
    private let titleLabel = UILabel()
    private let rightContainerView = UIView()
    private let bottomSeparatorView = UIView()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Setup Methods
    private func setupView() {
        // Set background color
        self.backgroundColor = .clear

        // Configure left container view
        leftContainerView.backgroundColor = .clear
        addSubview(leftContainerView)

        // Configure title label
        titleLabel.text = "Title"
        titleLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        addSubview(titleLabel)

        // Configure right container view
        rightContainerView.backgroundColor = .clear
        addSubview(rightContainerView)

        bottomSeparatorView.backgroundColor = .textPrimary.withAlphaComponent(0.08)
        addSubview(bottomSeparatorView)
        // Layout subviews
        setupConstraints()
    }

    private func setupConstraints() {
        leftContainerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        rightContainerView.translatesAutoresizingMaskIntoConstraints = false
        bottomSeparatorView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Left Container Constraints
            leftContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            leftContainerView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 20.0),
            leftContainerView.heightAnchor.constraint(equalTo: self.heightAnchor),
            leftContainerView.widthAnchor.constraint(lessThanOrEqualToConstant: 150),

            // Title Label Constraints
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 20.0),

            // Right Container Constraints
            rightContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            rightContainerView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            rightContainerView.heightAnchor.constraint(equalTo: self.heightAnchor),
            rightContainerView.widthAnchor.constraint(lessThanOrEqualToConstant: 150),
            
            bottomSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomSeparatorView.heightAnchor.constraint(equalToConstant: 1.0),
            bottomSeparatorView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // MARK: - Public Methods
    func setTitle(_ title: String?) {
        titleLabel.text = title
    }

    func setLeftCustomView(_ view: UIView) {
        leftContainerView.subviews.forEach { $0.removeFromSuperview() }
        view.translatesAutoresizingMaskIntoConstraints = false
        leftContainerView.addSubview(view)

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leftContainerView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: leftContainerView.trailingAnchor),
            view.topAnchor.constraint(equalTo: leftContainerView.topAnchor),
            view.bottomAnchor.constraint(equalTo: leftContainerView.bottomAnchor),
        ])
    }

    func setRightCustomView(_ view: UIView) {
        rightContainerView.subviews.forEach { $0.removeFromSuperview() }
        view.translatesAutoresizingMaskIntoConstraints = false
        rightContainerView.addSubview(view)

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: rightContainerView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: rightContainerView.trailingAnchor),
            view.topAnchor.constraint(equalTo: rightContainerView.topAnchor),
            view.bottomAnchor.constraint(equalTo: rightContainerView.bottomAnchor),
        ])
    }
}
