//
//  ScrollableStackViewMarqueeAnimator.swift
//  Ahsan Muslim
//
//  Created by Haider Rathore on 28/12/2024.
//

import UIKit

public protocol ScrollableStackViewMarqueeAnimatorDelegate: AnyObject {
    func marqueeAnimator(_ animator: ScrollableStackViewMarqueeAnimator, willMoveView view: UIView)
    func marqueeAnimator(_ animator: ScrollableStackViewMarqueeAnimator, didMoveView view: UIView)
    func marqueeAnimatorDidFinishRevolving(_ animator: ScrollableStackViewMarqueeAnimator)
}

public class ScrollableStackViewMarqueeAnimator {
    // MARK: - Private Properties

    private weak var scrollableStackView: ScrollableStackView?

    private var isAnimating = false

    private var displayLink: CADisplayLink?

    private var scrolledSubviewsCount: Int = 0

    // MARK: - Public properties

    public weak var delegate: ScrollableStackViewMarqueeAnimatorDelegate?

    /// Adjust for speed, points per frame. Higher value means faster animation. Default value is `1.0`
    public var animationSpeed: CGFloat

    /// Should keep animating after an iteration. Default value is `true`
    public var shouldAnimateInifitely: Bool

    // MARK: - Lifecycle

    public init(
        scrollView: ScrollableStackView,
        animationSpeed: CGFloat = 1.0,
        shouldAnimateInifitely: Bool = true,
        delegate: ScrollableStackViewMarqueeAnimatorDelegate? = nil
    ) {
        scrollableStackView = scrollView
        self.delegate = delegate
        self.animationSpeed = animationSpeed
        self.shouldAnimateInifitely = shouldAnimateInifitely
    }

    // MARK: - Public

    public func start() {
        guard !isAnimating else { return }

        isAnimating = true
        setupAnimationDisplayLink()
    }

    public func stop() {
        displayLink?.invalidate()
        displayLink = nil
        isAnimating = false
    }

    public func reset(_ shouldStop: Bool = true) {
        scrollableStackView?.contentOffset = .zero

        if shouldStop {
            stop()
        }
    }

    // MARK: - Private

    private func setupAnimationDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(animateScrollView))
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc
    private func animateScrollView() {
        guard let scrollableStackView else { return }

        // Adjust the contentOffset smoothly
        switch scrollableStackView.axis {
        case .horizontal:
            scrollableStackView.contentOffset.x += animationSpeed
            if let firstView = scrollableStackView.arrangedSubviews.first,
               firstView.frame.maxX < scrollableStackView.contentOffset.x {
                moveToLast(subview: firstView, in: scrollableStackView)
            }

        case .vertical:
            scrollableStackView.contentOffset.y += animationSpeed
            if let firstView = scrollableStackView.arrangedSubviews.first,
               firstView.frame.maxY < scrollableStackView.contentOffset.y {
                moveToLast(subview: firstView, in: scrollableStackView)
            }

        @unknown default:
            fatalError("Unsupported Axis!")
        }
    }

    private func moveToLast(subview view: UIView, in stackView: ScrollableStackView) {
        defer {
            scrolledSubviewsCount += 1

            if scrolledSubviewsCount == stackView.arrangedSubviews.count {
                scrolledSubviewsCount = 0
                delegate?.marqueeAnimatorDidFinishRevolving(self)
            }
        }

        guard shouldAnimateInifitely else { return }

        delegate?.marqueeAnimator(self, willMoveView: view)

        // Append the subview at the end of the stack view
        stackView.addArrangedSubview(view)

        // Adjust contentOffset to create a seamless looping effect
        if stackView.axis == .horizontal {
            let adjustment = view.frame.width + stackView.spacing
            stackView.contentOffset.x -= adjustment
        } else {
            let adjustment = view.frame.height + stackView.spacing
            stackView.contentOffset.y -= adjustment
        }

        delegate?.marqueeAnimator(self, didMoveView: view)
    }
}
