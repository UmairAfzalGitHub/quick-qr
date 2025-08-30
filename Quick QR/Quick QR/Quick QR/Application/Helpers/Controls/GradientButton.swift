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
        // Use legacy UIButton styling (so titleLabel?.font works)
        if #available(iOS 15.0, *) { self.configuration = nil }

        // If any attributed titles were set (IB or code), clear them so .font takes effect
        [UIControl.State.normal, .highlighted, .selected, .disabled].forEach {
            self.setAttributedTitle(nil, for: $0)
        }
        titleLabel?.font = .boldSystemFont(ofSize: 22)
        setTitleColor(.white, for: .normal)
        
        // Rounded corners
        layer.cornerRadius = 25
        layer.masksToBounds = false
        
        // Border
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2
        
        // Shadow
        layer.shadowColor = UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 0.7).cgColor
        layer.shadowOpacity = 0.6
        layer.shadowOffset = .zero
        layer.shadowRadius = 10
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Gradient
        gradientLayer.frame = bounds
        gradientLayer.colors = [
            UIColor.customColor(fromHex: "FFCA0F").cgColor, // light yellowish
            UIColor.customColor(fromHex: "FF8001").cgColor   // deep orange
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // top-center
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1.0) // bottom-center
        gradientLayer.cornerRadius = layer.cornerRadius
        
        if gradientLayer.superlayer == nil {
            layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
    func setBoldTitle(_ text: String, fontSize: CGFloat = 22, color: UIColor = .white) {
        let attr = NSAttributedString(
            string: text,
            attributes: [
                .font: UIFont.boldSystemFont(ofSize: fontSize),
                .foregroundColor: color
            ]
        )
        setAttributedTitle(attr, for: .normal)
    }
}
