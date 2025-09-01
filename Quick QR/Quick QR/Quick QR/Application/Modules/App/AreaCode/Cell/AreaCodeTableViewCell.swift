//
//  AreaCodeTableViewCell.swift
//  Phone Number Tracker
//
//  Created by Umair Afzal on 10/01/2025.
//

import Foundation
import UIKit
//import IOS_Helpers

class AreaCodeTableViewCell: UITableViewCell {

    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 12.0
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.Label.title
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let valueLabel: UILabel = {
        let label = UILabel()
        label.text = Strings.Label.value
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let copyButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(systemName: "doc.on.doc.fill")
        button.setImage(image, for: .normal)
        button.tintColor = .appPrimary
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
       super.init(style: style, reuseIdentifier: reuseIdentifier)
       backgroundColor = .clear
       selectionStyle = .none
        setup()
     }
    
     required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
     }

    private func setup() {
        backgroundColor = .appPrimaryBackground
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(valueLabel)
        containerView.addSubview(copyButton)

        copyButton.addTarget(self, action: #selector(didTapCopyButton), for: .touchUpInside)
        containerView.pinToSuperviewEdges(margin: 8.0)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16.0),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16.0),
            valueLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12.0),
            valueLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16.0),
            containerView.heightAnchor.constraint(equalToConstant: 70.0),
            copyButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16.0),
            copyButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }

    @objc func didTapCopyButton() {
        UIPasteboard.general.string = valueLabel.text
    }
}
