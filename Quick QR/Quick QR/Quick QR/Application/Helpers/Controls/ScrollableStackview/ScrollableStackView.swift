//
//  ScrollableStackView.swift
//  Ahsan Muslim
//
//  Created by Haider Rathore on 28/12/2024.
//

//    fullListContainerView.axis = .vertical
//    fullListContainerView.distribution = .fill
//    fullListContainerView.bounces = false
//    fullListContainerView.spacing = itemSpacing
//    fullListContainerView.showsVerticalScrollIndicator = true

import UIKit
/// A custom `UIStackView` with scrolling capabilities. Needs a width/height constraint along the `axis` to enable scrolling.
/// Just set `width` or `height` anchor(s) for `horizontal` and `vertical` `axis` respectively.
/// Behaves just like a regular `UIStackView` if no such constraint is provided along the `axis`.
public class ScrollableStackView: UIScrollView {
    // MARK: - Properties
    private let stackView = UIStackView()
    private lazy var stackWidthConstraint: NSLayoutConstraint = {
        let constraint = stackView.widthAnchor.constraint(equalTo: widthAnchor, constant: -1)
        constraint.priority = UILayoutPriority.defaultHigh
        return constraint
    }()
    private lazy var stackHeightConstraint: NSLayoutConstraint = {
        let constraint = stackView.heightAnchor.constraint(equalTo: heightAnchor, constant: -1)
        constraint.priority = UILayoutPriority.defaultHigh
        return constraint
    }()
    private lazy var stackTrailingConstraint: NSLayoutConstraint = {
        let constraint = stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1)
        constraint.priority = UILayoutPriority.defaultHigh
        return constraint
    }()
    private lazy var stackBottomConstraint: NSLayoutConstraint = {
        let constraint = stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1)
        constraint.priority = UILayoutPriority.defaultHigh
        return constraint
    }()
    // MARK: - Lifecycle
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override public func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    // MARK: - Public
    override public var directionalLayoutMargins: NSDirectionalEdgeInsets {
        get { stackView.directionalLayoutMargins }
        set { stackView.directionalLayoutMargins = newValue }
    }
    /// Determines whether scrolling is enabled based on the `intrinsicContentSize` along the `axis`, useful for handling inequality constraints. Default value is `true`
    public var disableIntrinsicContentSizeScrolling = true {
        didSet {
            updateStackViewConstraints()
        }
    }
    // MARK: - Stack View properties and methods (feel free to add more UIStackView methods :)
    public var axis: NSLayoutConstraint.Axis {
        get { stackView.axis }
        set {
            stackView.axis = newValue
            updateStackViewConstraints()
        }
    }
    public var alignment: UIStackView.Alignment {
        get { stackView.alignment }
        set { stackView.alignment = newValue }
    }
    public var distribution: UIStackView.Distribution {
        get { stackView.distribution }
        set { stackView.distribution = newValue }
    }
    public var spacing: CGFloat {
        get { stackView.spacing }
        set { stackView.spacing = newValue }
    }
    public var isLayoutMarginsRelativeArrangement: Bool {
        get { stackView.isLayoutMarginsRelativeArrangement }
        set { stackView.isLayoutMarginsRelativeArrangement = newValue }
    }
    public var arrangedSubviews: [UIView] {
        stackView.arrangedSubviews
    }
    public func addArrangedSubview(_ view: UIView) {
        stackView.addArrangedSubview(view)
    }
    public func removeArrangedSubview(_ view: UIView) {
        stackView.removeArrangedSubview(view)
    }
    public func addArrangedSubviews(_ views: [UIView]) {
        views.forEach { stackView.addArrangedSubview($0) }
    }
    public func removeArrangedSubviews(_ views: [UIView]) {
        views.forEach { stackView.removeArrangedSubview($0) }
    }
    public func addArrangedSubviews(_ views: UIView...) {
        views.forEach { stackView.addArrangedSubview($0) }
    }
    public func removeArrangedSubviews(_ views: UIView...) {
        views.forEach { stackView.removeArrangedSubview($0) }
    }
    public func insertArrangedSubview(_ view: UIView, at stackIndex: Int) {
        stackView.insertArrangedSubview(view, at: stackIndex)
    }
    public func removeArrangedSubview(at stackIndex: Int) {
        stackView.removeArrangedSubview(stackView.arrangedSubviews[stackIndex])
    }
    public func removeAllArrangedSubviews() {
        stackView.arrangedSubviews.forEach { stackView.removeArrangedSubview($0) }
    }
    public func setCustomSpacing(_ spacing: CGFloat, after view: UIView) {
        stackView.setCustomSpacing(spacing, after: view)
    }
    // MARK: - Private
    private func configure() {
        setupUi()
        updateStackViewConstraints()
    }
    private func setupUi() {
        translatesAutoresizingMaskIntoConstraints = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
    private func updateStackViewConstraints() {
        NSLayoutConstraint.deactivate([
            stackWidthConstraint,
            stackHeightConstraint,
            stackTrailingConstraint,
            stackBottomConstraint
        ])
        if disableIntrinsicContentSizeScrolling {
            if axis == .horizontal {
                // For horizontal axis, activate the height constraint and set up the width constraint
                stackHeightConstraint.isActive = true
                stackWidthConstraint.constant = -1
                stackWidthConstraint.isActive = true
            } else {
                // For vertical axis, activate the width constraint and set up the height constraint
                stackWidthConstraint.isActive = true
                stackHeightConstraint.constant = -1
                stackHeightConstraint.isActive = true
            }
        } else {
            if axis == .horizontal {
                stackHeightConstraint.isActive = true
                stackTrailingConstraint.isActive = true
            } else {
                stackWidthConstraint.isActive = true
                stackBottomConstraint.isActive = true
            }
        }
    }
}
