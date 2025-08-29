//
//  UIView+Extension.swift
//  Quick QR
//
//  Created by Umair Afzal on 29/08/2025.
//

import Foundation
import UIKit

extension UIView {
    func addSoftShadow(
        color: UIColor = .appPrimary,
        opacity: Float = 0.6,
        radius: CGFloat = 6
    ) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = .zero   // Important: shadow on all sides
        self.layer.shadowRadius = radius
        self.layer.masksToBounds = false
    }
}
