//
//  QRTypeCell.swift
//  Quick QR
//
//  Created by Umair Afzal on 30/08/2025.
//

import Foundation
import UIKit

class QRTypeCell: UICollectionViewCell {
    static let identifier = "QRTypeCell"
    
    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .black
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        lbl.textColor = .textPrimary
        return lbl
    }()
    
    private let boxView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 11
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.appBorderDark.cgColor
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(boxView)
        contentView.addSubview(titleLabel)
        boxView.addSubview(iconView)
        
        boxView.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Box constraints
            boxView.topAnchor.constraint(equalTo: contentView.topAnchor),
            boxView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            boxView.widthAnchor.constraint(equalToConstant: 60),
            boxView.heightAnchor.constraint(equalToConstant: 60),
            
            // Icon inside box
            iconView.centerXAnchor.constraint(equalTo: boxView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: boxView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),
            
            // Title below box
            titleLabel.topAnchor.constraint(equalTo: boxView.bottomAnchor, constant: 6),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(title: String, icon: UIImage?) {
        titleLabel.text = title
        iconView.image = icon
    }
}

