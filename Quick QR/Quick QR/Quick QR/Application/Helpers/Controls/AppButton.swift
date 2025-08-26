//
//  AppButton.swift
//  Photo Recovery
//
//  Created by Umair Afzal on 07/03/2025.
//

import Foundation
import UIKit

class AppButton: UIButton {
    //MARK: - Enum
    enum ButtonType {
        case primary
        case secondary
    }
    
    // MARK: - Variables
    private let buttonCornerRadius: CGFloat = 24
    private(set) var type: ButtonType = .primary
    
    // MARK: - Init Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton(type: type)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton(type: type)
    }
    
    // MARK: - Setup Methods
    func setupButton(type: ButtonType) {
        self.type = type
        layer.cornerRadius = buttonCornerRadius
        layer.borderWidth = 0.0
        clipsToBounds = true
        
        switch type {
        case .primary:
            backgroundColor = .appGreenMedium
            titleLabel?.textColor = .appSecondaryBackground
            isEnabled = true
            
        case .secondary:
            backgroundColor = .white
            titleLabel?.textColor = .appGreenMedium
            isEnabled = true
        }
        
        if let titleColor = self.titleLabel?.textColor {
            attributedTitle(for: .normal, color: titleColor)
            attributedTitle(for: .highlighted, color: titleColor)
            attributedTitle(for: .selected, color: titleColor)
        }
    }
    
    func setupAttributedTitle(normalText: String, attributedText: String) {
        // Configure the regular and bold attributes
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14.0),
            .foregroundColor: UIColor.red
        ]

        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14.0),
            .foregroundColor: UIColor.red
        ]

        let attributedString = NSMutableAttributedString(string: normalText, attributes: normalAttributes)
        attributedString.append(NSAttributedString(string: attributedText, attributes: boldAttributes))

        self.setAttributedTitle(attributedString, for: .normal)
        self.setAttributedTitle(attributedString, for: .selected)
        self.setAttributedTitle(attributedString, for: .highlighted)
    }
    
    override var isHighlighted: Bool {
        didSet {
            titleLabel?.font = getFont()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            titleLabel?.font = getFont()
        }
    }
    
    private func attributedTitle(for state: UIControl.State, color: UIColor) {
        let attributes: [NSAttributedString.Key: Any] = [ .font: getFont(), .foregroundColor: color ]
        let attributedTitle = NSAttributedString(string: self.titleLabel?.text ?? "-", attributes: attributes)
        self.setAttributedTitle(attributedTitle, for: state)
    }
    
    private func getFont() -> UIFont {
        UIFont.systemFont(ofSize: 17.0)
    }
}
