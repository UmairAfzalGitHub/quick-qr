//
//  FavouriteViewController.swift
//  Quick QR
//
//  Created by Umair Afzal on 28/08/2025.
//

import UIKit
import IOS_Helpers

class FavouriteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FavoriteCellDelegate {
    
    // MARK: - Properties
    private let tableView = UITableView()
    private let emptyStateView = UIView()
    private var favorites: [FavoriteItem] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites()
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        // Configure navigation bar appearance
        self.navigationItem.title = "Favorite"
        
        //        // Remove extra space at the top
        navigationController?.navigationBar.isTranslucent = false
        
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Configure table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FavoriteCell.self, forCellReuseIdentifier: FavoriteCell.identifier)
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.backgroundColor = .white
        tableView.rowHeight = 80
        
        // Remove extra space at the top
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.contentInset = UIEdgeInsets.zero
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        
        // Add table view to view hierarchy
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Setup empty state view
        setupEmptyStateView()
    }
    
    // MARK: - Data
    private func loadFavorites() {
        // Get all favorite items from HistoryManager
        let favoriteItems = HistoryManager.shared.getFavorites()
        
        // Convert HistoryItems to FavoriteItems
        favorites = favoriteItems.map { $0.toFavoriteItem() }
        
        // Refresh table view
        tableView.reloadData()
        
        // Show empty state if needed
        if favorites.isEmpty {
            showEmptyState()
        } else {
            hideEmptyState()
        }
    }
    
    // MARK: - UITableViewDelegate & UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.identifier, for: indexPath) as? FavoriteCell else {
            return UITableViewCell()
        }
        
        let favorite = favorites[indexPath.row]
        cell.configure(with: favorite)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Handle selection
    }
    
    // MARK: - FavoriteCellDelegate
    
    func didTapFavouriteButton(cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        // Get the item ID from our data source
        let itemId = favorites[indexPath.row].id
        
        // Toggle favorite status in the history manager (will unfavorite it)
        let isFavorite = HistoryManager.shared.toggleFavorite(forItemWithId: itemId)
        
        // Since this is the favorites tab, if it's still marked as favorite (which shouldn't happen),
        // we need to update the UI to reflect the current state
        if !isFavorite {
            // Remove from our data source
            favorites.remove(at: indexPath.row)
            
            // Animate the removal
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // Show empty state if needed
            if favorites.isEmpty {
                showEmptyState()
            }
        } else {
            // Just reload the row if for some reason it's still favorited
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func didTapOptionsButton(cell: UITableViewCell) {
        // Handle options button tap if needed
    }
    
    // MARK: - Empty State Handling
    
    private func setupEmptyStateView() {
        emptyStateView.isHidden = true
        view.addSubview(emptyStateView)
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
        ])
        
        let imageView = UIImageView(image: UIImage(systemName: "heart"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .red
        
        let titleLabel = UILabel()
        titleLabel.text = "No Favorites Yet"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textAlignment = .center
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Tap the heart icon on any item to add it to favorites"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .systemGray
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .center
        
        emptyStateView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            stackView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }
    
    private func showEmptyState() {
        tableView.isHidden = true
        emptyStateView.isHidden = false
    }
    
    private func hideEmptyState() {
        tableView.isHidden = false
        emptyStateView.isHidden = true
    }
}


// MARK: - Models
struct FavoriteItem {
    enum ItemType {
        case qrCode(QRCodeType)
        case socialQRCode(SocialQRCodeType)
        case barCode(BarCodeType)
    }
    
    let type: ItemType
    let title: String
    let url: String
    let id: String
    var isFavorite: Bool
    
    init(type: ItemType, title: String, url: String, id: String = UUID().uuidString, isFavorite: Bool = false) {
        self.type = type
        self.title = title
        self.url = url
        self.id = id
        self.isFavorite = isFavorite
    }
}
