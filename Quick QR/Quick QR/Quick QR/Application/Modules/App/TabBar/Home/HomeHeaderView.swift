//
//  HomeHeaderView.swift
//  Quick QR
//
//  Created by Umair Afzal on 30/08/2025.
//

import Foundation
import UIKit

class HomeHeaderView: UICollectionReusableView {
    static let identifier = "HomeHeaderView"
    
    private let label: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 16)
        lbl.textColor = .black
        return lbl
    }()
    
    var title: String? {
        didSet { label.text = title }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
}
