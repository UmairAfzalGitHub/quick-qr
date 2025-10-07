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
    
    private let lockOverlayView: UIView = {
        let v = UIView()
        v.backgroundColor = .appLockedBackground
        v.layer.cornerRadius = 11
        v.isHidden = true
        return v
    }()
    
    private let lockIconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "iap-lock")
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(boxView)
        contentView.addSubview(titleLabel)
        
        // Add lock overlay
        boxView.addSubview(lockOverlayView)
        lockOverlayView.addSubview(lockIconView)
        
        boxView.addSubview(iconView)
        
        boxView.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        lockOverlayView.translatesAutoresizingMaskIntoConstraints = false
        lockIconView.translatesAutoresizingMaskIntoConstraints = false
        
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
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
            
            // Lock overlay constraints
            lockOverlayView.topAnchor.constraint(equalTo: boxView.topAnchor),
            lockOverlayView.leadingAnchor.constraint(equalTo: boxView.leadingAnchor),
            lockOverlayView.trailingAnchor.constraint(equalTo: boxView.trailingAnchor),
            lockOverlayView.bottomAnchor.constraint(equalTo: boxView.bottomAnchor),
            
            // Lock icon constraints
            lockIconView.topAnchor.constraint(equalTo: lockOverlayView.topAnchor, constant: 1),
            lockIconView.trailingAnchor.constraint(equalTo: lockOverlayView.trailingAnchor, constant: -1),
            lockIconView.widthAnchor.constraint(equalToConstant:20),
            lockIconView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(title: String, icon: UIImage?) {
        titleLabel.text = title
        iconView.image = icon
    }
    
    func showLockOverlay(_ show: Bool) {
        lockOverlayView.isHidden = !show
        boxView.layer.borderColor =  show ? UIColor.appLockedCorner.cgColor : UIColor.appBorderDark.cgColor
    }
}

