//
//  FavouriteViewController.swift
//  Quick QR
//
//  Created by Umair Afzal on 28/08/2025.
//

import UIKit
import IOS_Helpers

class FavouriteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    private let tableView = UITableView()
    private var favorites: [FavoriteItem] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        loadFavorites()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    }
    
    // MARK: - Data
    private func loadFavorites() {
        // Mock data for demonstration
        favorites = [
            FavoriteItem(type: .qrCode(.website), title: "Website", url: "https://www.google.com"),
            FavoriteItem(type: .qrCode(.email), title: "Email", url: "mailto:example@example.com"),
            FavoriteItem(type: .socialQRCode(.whatsapp), title: "WhatsApp", url: "https://wa.me/1234567890")
        ]
        tableView.reloadData()
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
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Handle selection
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
}
