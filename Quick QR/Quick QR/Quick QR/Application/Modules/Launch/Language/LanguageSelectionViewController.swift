//
//  LanguageSelectionViewController.swift
//
//
//  Created by Haider Rathore on 26/08/2025.
//

import UIKit

class LanguageSelectionViewController: UIViewController {
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Language"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    private let selectCTA: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBlue
        view.layer.cornerRadius = 15
        let label = UILabel()
        label.text = "Select"
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }()
    
    private var collectionView: UICollectionView!
    
    private let adContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemOrange
        return view
    }()
    
    // MARK: - Data
    struct Language {
        let name: String
        let flag: UIImage?
    }
    
    private var languages: [Language] = [
        Language(name: "Arabic", flag: UIImage(named: "saudi-arabia-flag")),
        Language(name: "Chinese", flag: UIImage(named: "china-flag")),
        Language(name: "English", flag: UIImage(named: "uk-flag")),
        Language(name: "French", flag: UIImage(named: "france-flag")),
        Language(name: "Hindi", flag: UIImage(named: "india-flag")),
        Language(name: "Indonesia", flag: UIImage(named: "indonesia-flag")),
        Language(name: "Italian", flag: UIImage(named: "italy-flag")),
        Language(name: "Russian", flag: UIImage(named: "russia-flag")),
        Language(name: "Spanish", flag: UIImage(named: "spain-flag")),
        Language(name: "Urdu", flag: UIImage(named: "pakistan-flag"))
    ]
    
    private var selectedIndex: IndexPath?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCollectionView()
        setupLayout()
    }
    
    // MARK: - Setup Collection View
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 16
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(LanguageCell.self, forCellWithReuseIdentifier: "LanguageCell")
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    // MARK: - Setup Layout
    private func setupLayout() {
        let headerStack = UIStackView(arrangedSubviews: [titleLabel, UIView(), selectCTA])
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = 8
        
        view.addSubview(headerStack)
        view.addSubview(collectionView)
        view.addSubview(adContainer)
        
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        adContainer.translatesAutoresizingMaskIntoConstraints = false
        selectCTA.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            selectCTA.widthAnchor.constraint(equalToConstant: 80),
            selectCTA.heightAnchor.constraint(equalToConstant: 35),
            
            collectionView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: adContainer.topAnchor, constant: -10),
            
            adContainer.heightAnchor.constraint(equalToConstant: 280),
            adContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            adContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            adContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - CollectionView Delegate & DataSource
extension LanguageSelectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return languages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LanguageCell", for: indexPath) as! LanguageCell
        let lang = languages[indexPath.item]
        cell.configure(with: lang, isSelected: selectedIndex == indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let previous = selectedIndex
        selectedIndex = indexPath
        var reloads: [IndexPath] = [indexPath]
        if let prev = previous { reloads.append(prev) }
        collectionView.reloadItems(at: reloads)
    }
    
    // Grid layout 2 columns
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 16) / 2
        return CGSize(width: width, height: 64)
    }
}

// MARK: - Custom Cell
class LanguageCell: UICollectionViewCell {
    
    private let cellContentView = UIView()
    private let flagImageView = UIImageView()
    private let nameLabel = UILabel()
    private let checkmarkImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Setup content container (border + radius only, no shadow here)
        cellContentView.layer.cornerRadius = 7
        cellContentView.layer.borderColor = UIColor.appBorderDark.cgColor
        cellContentView.layer.borderWidth = 1
        cellContentView.backgroundColor = .white
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cellContentView)

        flagImageView.contentMode = .scaleAspectFit
        flagImageView.clipsToBounds = true
        flagImageView.layer.cornerRadius = 4
        
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        nameLabel.textColor = .black
        
        checkmarkImageView.contentMode = .scaleAspectFit
        checkmarkImageView.isHidden = true
        checkmarkImageView.image = UIImage(named: "checkmark-selected")
        
        let stack = UIStackView(arrangedSubviews: [flagImageView, nameLabel, checkmarkImageView])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 6
        
        cellContentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cellContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            cellContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            cellContentView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cellContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            stack.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -8),
            stack.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor, constant: -8)
        ])
        
        flagImageView.widthAnchor.constraint(equalToConstant: 38).isActive = true
        flagImageView.heightAnchor.constraint(equalToConstant: 38).isActive = true
        checkmarkImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        checkmarkImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        // Important: shadow setup on CELL itself
        contentView.layer.masksToBounds = false
        layer.masksToBounds = false
    }
    
    func configure(with language: LanguageSelectionViewController.Language, isSelected: Bool) {
        flagImageView.image = language.flag
        nameLabel.text = language.name
        checkmarkImageView.isHidden = !isSelected
        
        if isSelected {
            // Apply shadow to CELL, not inner view
            cellContentView.layer.borderColor = UIColor.appPrimary.cgColor
            cellContentView.layer.borderWidth = 1
            
            layer.shadowColor = UIColor.appPrimary.cgColor
            layer.shadowOpacity = 0.4
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowRadius = 6
        } else {
            cellContentView.layer.borderColor = UIColor.appBorderDark.cgColor
            layer.shadowOpacity = 0
        }
    }
}
