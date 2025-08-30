//
//  GradientButton.swift
//  Quick QR
//
//  Created by Umair Afzal on 30/08/2025.
//

import Foundation
import UIKit

class GradientButton: UIButton {
    
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        // Title style
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        // Rounded corners
        layer.cornerRadius = 25
        layer.masksToBounds = false
        
        // Border
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
        
        // Shadow
        layer.shadowColor = UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 0.7).cgColor
        layer.shadowOpacity = 0.6
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 10
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Gradient
        gradientLayer.frame = bounds
        gradientLayer.colors = [
            UIColor(red: 1.0, green: 0.75, blue: 0.2, alpha: 1).cgColor, // light yellowish
            UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1).cgColor   // deep orange
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.cornerRadius = layer.cornerRadius
        
        if gradientLayer.superlayer == nil {
            layer.insertSublayer(gradientLayer, at: 0)
        }
    }
}
