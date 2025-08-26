//
//  AnimatedProgressBar.swift
//  Quick QR
//
//  Created by Umair Afzal on 26/08/2025.
//

import Foundation
import UIKit

@IBDesignable
class AnimatedProgressBar: UIView {

    // MARK: - Public properties
    var trackColor: UIColor = .systemBlue {
        didSet {
            trackView.backgroundColor = trackColor
        }
    }

    var backgroundTrackColor: UIColor = .lightGray {
        didSet {
            backgroundView.backgroundColor = backgroundTrackColor
        }
    }

    // MARK: - Private Views
    private let backgroundView = UIView()
    private let trackView = UIView()

    private var isIndeterminate = false

    // Store animation block until layout is ready
    private var pendingFillAnimation: (() -> Void)?

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.frame = bounds
        backgroundView.layer.cornerRadius = backgroundView.frame.height / 2
        trackView.layer.cornerRadius = backgroundView.frame.height / 2

        if let pending = pendingFillAnimation {
            pending()
            pendingFillAnimation = nil
        }
    }

    private func setup() {
        backgroundColor = .clear

        backgroundView.backgroundColor = backgroundTrackColor
        backgroundView.clipsToBounds = true

        trackView.backgroundColor = trackColor
        trackView.clipsToBounds = true

        backgroundView.addSubview(trackView)
        addSubview(backgroundView)
    }

    // MARK: - Behavior 1: Linear Fill Animation
    func animateFill(duration: TimeInterval, completion: (() -> Void)? = nil) {
        isIndeterminate = false
        pendingFillAnimation = { [weak self] in
            guard let self = self else { return }

            self.trackView.frame = CGRect(x: 0, y: 0, width: 0, height: self.backgroundView.frame.height)

            UIView.animate(withDuration: duration, delay: 0, options: .curveLinear, animations: {
                self.trackView.frame.size.width = self.backgroundView.frame.width
            }, completion: { _ in
                completion?()
            })
        }
        setNeedsLayout()
    }

    // MARK: - Behavior 2: Indeterminate Animation (with speed)
    func animateIndeterminate(duration: TimeInterval, speed: TimeInterval = 1.0, completion: (() -> Void)? = nil) {
        isIndeterminate = true

        pendingFillAnimation = { [weak self] in
            guard let self = self else { return }

            let barWidth = self.bounds.width / 3
            self.trackView.frame = CGRect(x: -barWidth, y: 0, width: barWidth, height: self.backgroundView.frame.height)

            let animation = CABasicAnimation(keyPath: "position.x")
            animation.fromValue = -barWidth
            animation.toValue = self.bounds.width + barWidth
            animation.duration = speed
            animation.repeatCount = .infinity
            animation.timingFunction = CAMediaTimingFunction(name: .linear)

            self.trackView.layer.add(animation, forKey: "indeterminateAnimation")

            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.trackView.layer.removeAnimation(forKey: "indeterminateAnimation")
                completion?()
            }
        }
        setNeedsLayout()
    }
}
