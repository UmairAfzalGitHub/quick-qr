//
//  SubscriptionOptionView.swift
//  GhostVPN
//
//  Created by Haider on 11/11/2024.
//

import UIKit

protocol SubscriptionOptionDelegate: AnyObject {
    func subscriptionOptionDidSelect(_ option: SubscriptionOptionView)
}

class SubscriptionOptionView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var cellViewHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: SubscriptionOptionDelegate?
    private(set) var isSelected: Bool = false
    private var originalBackgroundImage: UIImage?
    
    //MARK: - Variables
    var view: UIView!
    
    // MARK: - Init Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }
    
    private func nibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        addSubview(view)
        setUI()
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return nibView
    }
    
    private func setUI() {
        backgroundView.layer.cornerRadius = 12
        updateSelectionState()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Public Methods
    func configure(title: String, price: String) {
        titleLabel.text = title
        priceLabel.text = price
        let cellHeight = UIDevice().isSmallerDevice() ? 55 : 80
        cellViewHeightConstraint.constant = CGFloat(cellHeight)
    }
    
    func setSelected(_ selected: Bool) {
        isSelected = selected
        updateSelectionState()
    }

    // MARK: - Private Methods
    private func updateSelectionState() {
        if isSelected {
            backgroundView.layer.borderWidth = 2
            backgroundView.layer.borderColor = UIColor.appGreenMedium.cgColor
            backgroundView.backgroundColor = .appGreenMedium.withAlphaComponent(0.4)

        } else {
            backgroundView.backgroundColor = .appGreenMedium.withAlphaComponent(0.1)
            backgroundView.layer.borderWidth = 0
        }
    }
    
    @objc private func viewTapped() {
        delegate?.subscriptionOptionDidSelect(self)
    }
}
