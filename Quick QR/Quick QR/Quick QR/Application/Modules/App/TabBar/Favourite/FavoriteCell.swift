//
//  FavoriteCell.swift
//  Quick QR
//
//  Created by Umair Afzal on 29/08/2025.
//

import Foundation
import UIKit

protocol FavoriteCellDelegate: AnyObject {
    func didTapFavouriteButton(cell: UITableViewCell)
    func didTapOptionsButton(cell: UITableViewCell)
}

class FavoriteCell: UITableViewCell {
    static let identifier = "FavoriteCell"
    
    // UI Components
    private let iconContainerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let urlLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)
    private let optionsButton = UIButton(type: .system)
    
    // Item data
    private var itemId: String = ""
    private var isFavorite: Bool = false
    
    weak var delegate: FavoriteCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .white
        
        // Icon container
        iconContainerView.translatesAutoresizingMaskIntoConstraints = false
        iconContainerView.layer.cornerRadius = 11
        iconContainerView.layer.borderWidth = 1
        iconContainerView.layer.borderColor = UIColor.appBorderDark.cgColor
        iconContainerView.clipsToBounds = true
        contentView.addSubview(iconContainerView)
        
        // Icon
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .black
        iconContainerView.addSubview(iconImageView)
        
        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = UIColor.customColor(fromHex: "1B2137")
        contentView.addSubview(titleLabel)
        
        // URL
        urlLabel.translatesAutoresizingMaskIntoConstraints = false
        urlLabel.font = UIFont.systemFont(ofSize: 14)
        urlLabel.textColor = .gray
        contentView.addSubview(urlLabel)
        
        // Favorite button
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.tintColor = .systemGray
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        contentView.addSubview(favoriteButton)
        
        // Options button (three dots)
        optionsButton.translatesAutoresizingMaskIntoConstraints = false
        optionsButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        optionsButton.tintColor = UIColor.customColor(fromHex: "1B2137")
        optionsButton.addTarget(self, action: #selector(optionsButtonTapped), for: .touchUpInside)
        contentView.addSubview(optionsButton)
        
        // Layout
        NSLayoutConstraint.activate([
            // Icon container
            iconContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconContainerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 50),
            iconContainerView.heightAnchor.constraint(equalToConstant: 50),
            
            // Icon inside container
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: favoriteButton.leadingAnchor, constant: -12),
            
            urlLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            urlLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            urlLabel.trailingAnchor.constraint(lessThanOrEqualTo: favoriteButton.leadingAnchor, constant: -12),
            
            optionsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            optionsButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            optionsButton.widthAnchor.constraint(equalToConstant: 30),
            optionsButton.heightAnchor.constraint(equalToConstant: 30),
            
            favoriteButton.trailingAnchor.constraint(equalTo: optionsButton.leadingAnchor, constant: -8),
            favoriteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 30),
            favoriteButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func configure(with item: FavoriteItem) {
        titleLabel.text = item.title
        urlLabel.text = item.url
        itemId = item.id
        isFavorite = item.isFavorite
        
        // Set icon based on type
        switch item.type {
        case .qrCode(let qrType):
            iconImageView.image = qrType.icon
        case .socialQRCode(let socialType):
            iconImageView.image = socialType.icon
        case .barCode(let barType):
            iconImageView.image = barType.icon
        }
        
        // Update favorite button appearance
        updateFavoriteButtonAppearance()
    }
    
    private func updateFavoriteButtonAppearance() {
        if isFavorite {
            favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            favoriteButton.tintColor = .red
        } else {
            favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
            favoriteButton.tintColor = .systemGray
        }
    }

    @objc private func favoriteButtonTapped() {
        delegate?.didTapFavouriteButton(cell: self)
    }
    
    @objc private func optionsButtonTapped() {
        delegate?.didTapOptionsButton(cell: self)
    }
}
