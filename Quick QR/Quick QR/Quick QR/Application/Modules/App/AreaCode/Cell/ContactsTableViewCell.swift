//
//  ContactsTableViewCell.swift
//  Phone Number Tracker
//
//  Created by Haider Rathore on 03/01/2025.
//

import UIKit

protocol ContactsTableViewCellDelegate: AnyObject {
    func didTapCopy(text: String)
}

class ContactsTableViewCell: UITableViewCell {

    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var imageBackgroundView: UIView!
    @IBOutlet weak var rightImageBackgroundView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    weak var delegate: ContactsTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }

    func style() {
//        cellBackgroundView.layer.cornerRadius = 12
        imageBackgroundView.layer.cornerRadius = 8
        rightImageBackgroundView.layer.cornerRadius = 8
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCopyButton))
        rightImageView.addGestureRecognizer(tapGesture)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(city: City) {
        imageBackgroundView.isHidden = true
        nameLabel.text = city.cityName
        numberLabel.text = city.phoneCode
        rightImageView.image = UIImage(systemName: "doc.on.doc.fill")
        rightImageView.tintColor = .appPrimary
        rightImageView.isUserInteractionEnabled = true
    }
    
    @objc func didTapCopyButton() {
        delegate?.didTapCopy(text: numberLabel.text ?? "")
    }
}
