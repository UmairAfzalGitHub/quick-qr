
import Foundation
import UIKit

class CustomPageControl: UIView {
    
    var numberOfPages: Int = 0 {
        didSet {
            setupDots()
        }
    }
    
    var currentPage: Int = 0 {
        didSet {
            updateDots()
        }
    }
    
    var dotSize: CGFloat = 8.0
    var spacing: CGFloat = 3.0
    var activeColor: UIColor = .red
    var inactiveColor: UIColor = .green
    
    private let stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStackView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStackView()
    }
    
    private func setupStackView() {
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 1
        stackView.distribution = .equalSpacing
        
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    private func setupDots() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for index in 0..<numberOfPages {
            let dot = UIView()
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.backgroundColor = index == currentPage ? activeColor : inactiveColor
            stackView.addArrangedSubview(dot)
            
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: dotSize),
                dot.heightAnchor.constraint(equalToConstant: dotSize)
            ])
        }
        
        updateDots()
    }
    
    private func updateDots() {
        for (index, view) in stackView.arrangedSubviews.enumerated() {
            if let dot = view as? UIView {
                dot.backgroundColor = index == currentPage ? activeColor : inactiveColor
                let newWidth = index == currentPage ? dotSize * 2.7 : dotSize // Width of Active Dot
                dot.layer.cornerRadius = dotSize / 2
                
                dot.constraints.forEach { constraint in
                    if constraint.firstAttribute == .width {
                        constraint.constant = newWidth
                    } else if constraint.firstAttribute == .height {
                        constraint.constant = dotSize
                    }
                }
            }
        }
    }
}
