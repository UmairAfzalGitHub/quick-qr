//
//  HistoryViewController.swift
//  Quick QR
//
//  Created by Umair Afzal on 29/08/2025.
//

import Foundation
import UIKit
import BetterSegmentedControl
import IOS_Helpers
import AVFoundation

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FavoriteCellDelegate {
    
    private let betterSegmentedControl: BetterSegmentedControl = {
        let control = BetterSegmentedControl(
            frame: CGRect.zero,
            segments: LabelSegment.segments(withTitles: ["Scan", "Created"],
                                            normalFont: UIFont.systemFont(ofSize: 16, weight: .semibold),
                                          normalTextColor: UIColor.systemGray,
                                            selectedFont: UIFont.systemFont(ofSize: 16, weight: .semibold),
                                          selectedTextColor: UIColor.white),
            options: [.backgroundColor(.appSecondaryBackground),
                      .indicatorViewBackgroundColor(.appPrimary),
                     .cornerRadius(27),
                     .animationSpringDamping(1.0),
                     .animationDuration(0.3)])
        control.indicatorViewInset = 6.0
        control.indicatorView.addSoftShadow()
        control.setIndex(0)
        return control
    }()
    
    private let tableView = UITableView()
    private let emptyStateView = UIView()
    private var isScanSelected: Bool {
        return betterSegmentedControl.index == 0
    }
    
    private var dataSource: [FavoriteItem] = []
    private var scanDataSource: [HistoryItem] = []
    private var createdDataSource: [HistoryItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadHistory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Fetch and store both scan and created history
        scanDataSource = HistoryManager.shared.getScanHistory()
        createdDataSource = HistoryManager.shared.getCreatedHistory()
        loadHistory()
        // Update clear button visibility based on data
        navigationItem.rightBarButtonItem?.isEnabled = !dataSource.isEmpty
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Add Better Segmented Control
        view.addSubview(betterSegmentedControl)
        betterSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        // Add value changed action
        betterSegmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            betterSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            betterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            betterSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            betterSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            betterSegmentedControl.heightAnchor.constraint(equalToConstant: 54)
        ])
        
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
            tableView.topAnchor.constraint(equalTo: betterSegmentedControl.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Setup empty state view
        setupEmptyStateView()
    }

    private func loadHistory() {
        let historyItems = isScanSelected ? 
            HistoryManager.shared.getScanHistory() : 
            HistoryManager.shared.getCreatedHistory()
        let origin: FavoriteItem.Origin = isScanSelected ? .scanned : .created
        dataSource = historyItems.map { $0.toFavoriteItem(origin: origin) }
        tableView.reloadData()
        
        // Show empty state if needed
        if dataSource.isEmpty {
            showEmptyState()
        } else {
            hideEmptyState()
        }
    }
    
    @objc private func segmentChanged(_ sender: BetterSegmentedControl) {
        // Reload history when segment changes
        loadHistory()
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
        
        let imageView = UIImageView(image: UIImage(systemName: "clock.arrow.circlepath"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .appPrimary
        
        let titleLabel = UILabel()
        titleLabel.text = "No History Yet"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textAlignment = .center
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Your generated codes will appear here"
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
    
    // MARK: - UITableViewDelegate & UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.identifier, for: indexPath) as? FavoriteCell else {
            return UITableViewCell()
        }
        
        let favorite = dataSource[indexPath.row]
        cell.configure(with: favorite)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Only handle selection in the Created tab
        if !isScanSelected {
            // Use local createdDataSource
            guard indexPath.row < createdDataSource.count else { return }
            let selectedItem = createdDataSource[indexPath.row]

            let resultVC = CodeGenerationResultViewController()
            switch selectedItem.type {
            case .qrCode:
                if let qrImage = CodeGeneratorManager.shared.generateQRCode(from: selectedItem.content) {
                    resultVC.setQRCodeImage(qrImage)
                }
                resultVC.setTitleAndDescription(title: selectedItem.title, description: "QR Code")
            case .socialQRCode:
                if let socialType = SocialQRCodeType.allCases.first(where: { $0.title.lowercased() == selectedItem.subtype.lowercased() }) {
                    if let qrImage = CodeGeneratorManager.shared.generateSocialQRCode(type: socialType, username: selectedItem.content) {
                        resultVC.setQRCodeImage(qrImage)
                    }
                    resultVC.setTitleAndDescription(title: selectedItem.title, description: "Social QR")
                }
            case .barCode:
                if let barType = BarCodeType.allCases.first(where: { $0.title.lowercased() == selectedItem.subtype.lowercased() }) {
                    if let barcodeImage = CodeGeneratorManager.shared.generateBarcode(content: selectedItem.content, type: barType) {
                        resultVC.setBarCodeImage(barcodeImage)
                        resultVC.setBarCodeType(icon: barType.icon, title: barType.title)
                    }
                    resultVC.setTitleAndDescription(title: selectedItem.title, description: "Barcode")
                }
            }
            navigationController?.pushViewController(resultVC, animated: true)
        } else {
            // Use local scanDataSource
            guard indexPath.row < scanDataSource.count else { return }
            let selectedItem = scanDataSource[indexPath.row]
            // Try to infer code type
            var metadataType: AVMetadataObject.ObjectType = .qr
            // If the subtype matches a barcode type, treat as barcode
            if let barType = BarCodeType.allCases.first(where: { $0.title.lowercased() == selectedItem.subtype.lowercased() }) {
                metadataType = barType.metadataObjectType
            } else if let _ = QRCodeType.allCases.first(where: { $0.title.lowercased() == selectedItem.subtype.lowercased() }) {
                metadataType = .qr
            } else if let _ = SocialQRCodeType.allCases.first(where: { $0.title.lowercased() == selectedItem.subtype.lowercased() }) {
                metadataType = .qr
            }
            let scanResultVC = ScanResultViewController(scannedData: selectedItem.content, metadataObjectType: metadataType)
            navigationController?.pushViewController(scanResultVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Get the history items
            let historyItems = isScanSelected ? 
                HistoryManager.shared.getScanHistory() : 
                HistoryManager.shared.getCreatedHistory()
            
            // Delete the item from history manager
            if indexPath.row < historyItems.count {
                let itemToDelete = historyItems[indexPath.row]
                HistoryManager.shared.deleteHistoryItem(withId: itemToDelete.id)
                
                // Remove from data source
                dataSource.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                // Show empty state if needed
                if dataSource.isEmpty {
                    showEmptyState()
                }
            }
        }
    }
    
    // MARK: - FavoriteCellDelegate
    
    func didTapFavouriteButton(cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        // Get the item ID from our data source
        let itemId = dataSource[indexPath.row].id
        
        // Toggle favorite status in the history manager
        let newFavoriteStatus = HistoryManager.shared.toggleFavorite(forItemWithId: itemId)
        
        // Update our data source
        dataSource[indexPath.row].isFavorite = newFavoriteStatus
        
        // Reload just this cell to update the UI
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func didTapOptionsButton(cell: UITableViewCell) {
        // Handle options button tap if needed
    }
}
