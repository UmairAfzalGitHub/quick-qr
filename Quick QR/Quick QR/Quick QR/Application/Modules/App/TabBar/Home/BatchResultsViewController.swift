//
//  BatchResultsViewController.swift
//  Quick QR
//
//  Created on 08/03/2026.
//

import UIKit
import AVFoundation

/// Displays all items collected during a batch scanning session.
/// Follows the same visual style as SettingsViewController (`.systemBackground`, `.grouped` table).
final class BatchResultsViewController: UIViewController {
    
    // MARK: - Properties
    var batchItems: [BatchScanItem] = []
    var onClearAll: (() -> Void)?
    var isFromHistory: Bool = false
    
    // MARK: - UI
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .systemBackground
        tv.separatorStyle = .singleLine
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let emptyStateView: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.isHidden = true
        
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 48, weight: .light)
        let icon = UIImageView(image: UIImage(systemName: "tray", withConfiguration: iconConfig))
        icon.tintColor = .tertiaryLabel
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.text = "No scanned codes yet"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let sublabel = UILabel()
        sublabel.text = "Enable batch mode and start scanning"
        sublabel.font = .systemFont(ofSize: 13, weight: .regular)
        sublabel.textColor = .tertiaryLabel
        sublabel.textAlignment = .center
        sublabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(icon)
        container.addSubview(label)
        container.addSubview(sublabel)
        
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            icon.topAnchor.constraint(equalTo: container.topAnchor),
            icon.widthAnchor.constraint(equalToConstant: 60),
            icon.heightAnchor.constraint(equalToConstant: 60),
            label.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 12),
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            sublabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 4),
            sublabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            sublabel.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        return container
    }()
    
    private let saveAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save All to History", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .appPrimary
        button.layer.cornerRadius = 14
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Shadow
        button.layer.shadowColor = UIColor.appPrimary.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.25
        button.layer.masksToBounds = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Batch Scan Results"
        
        navigationController?.navigationBar.tintColor = .appPrimary
        
        // Clear All button (only if not viewing from history)
        if !isFromHistory {
            let clearButton = UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(clearAllTapped))
            clearButton.tintColor = .systemRed
            navigationItem.rightBarButtonItem = clearButton
        }
        
        setupUI()
        updateEmptyState()
    }
    
    // MARK: - Setup
    private func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BatchScanCell.self, forCellReuseIdentifier: BatchScanCell.reuseId)
        
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(saveAllButton)
        
        saveAllButton.addTarget(self, action: #selector(saveAllTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: isFromHistory ? view.bottomAnchor : saveAllButton.topAnchor, constant: -12),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            emptyStateView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -80),
            
            saveAllButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveAllButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveAllButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            saveAllButton.heightAnchor.constraint(equalToConstant: 52),
        ])
    }
    
    private func updateEmptyState() {
        let isEmpty = batchItems.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        saveAllButton.isHidden = isEmpty || isFromHistory
        navigationItem.rightBarButtonItem?.isEnabled = !isEmpty && !isFromHistory
    }
    
    // MARK: - Actions
    @objc private func clearAllTapped() {
        let alert = UIAlertController(
            title: "Clear All Scans?",
            message: "This will remove all \(batchItems.count) scanned items from this batch.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { [weak self] _ in
            self?.batchItems.removeAll()
            self?.tableView.reloadData()
            self?.updateEmptyState()
            self?.onClearAll?()
        })
        present(alert, animated: true)
    }
    
    @objc private func saveAllTapped() {
        // Animate button press
        UIView.animate(withDuration: 0.1, animations: {
            self.saveAllButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.saveAllButton.transform = .identity
            }
        }
        
        // Save entire batch as a single history item
        HistoryManager.shared.saveBatchScanHistory(batchItems)
        showToast("Batch saved to history!")
    }
    
    func deleteItem(at index: Int) {
        batchItems.remove(at: index)
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        updateEmptyState()
    }
    
    private func showToast(_ message: String) {
        ScanResultManager.shared.showToast(message: message, on: view)
    }
}

// MARK: - UITableViewDataSource & Delegate
extension BatchResultsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return batchItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BatchScanCell.reuseId, for: indexPath) as! BatchScanCell
        let item = batchItems[indexPath.row]
        cell.configure(with: item, index: indexPath.row + 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = batchItems[indexPath.row]
        let resultVC = ScanResultViewController(scannedData: item.value, metadataObjectType: item.type)
        resultVC.intent = .history
        navigationController?.pushViewController(resultVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemBackground
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "\(batchItems.count) Scanned Items"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = .black
        
        headerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.deleteItem(at: indexPath.row)
            completion(true)
        }
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - Custom Cell

final class BatchScanCell: UITableViewCell {
    static let reuseId = "BatchScanCell"
    
    private let indexLabel: UILabel = {
        let lb = UILabel()
        lb.font = .systemFont(ofSize: 12, weight: .bold)
        lb.textColor = .white
        lb.textAlignment = .center
        lb.backgroundColor = .appPrimary
        lb.layer.cornerRadius = 12
        lb.layer.masksToBounds = true
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.font = .systemFont(ofSize: 15, weight: .semibold)
        lb.textColor = .textPrimary
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    private let valueLabel: UILabel = {
        let lb = UILabel()
        lb.font = .systemFont(ofSize: 13, weight: .regular)
        lb.textColor = .secondaryLabel
        lb.lineBreakMode = .byTruncatingTail
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .systemBackground
        accessoryType = .disclosureIndicator
        
        contentView.addSubview(indexLabel)
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            indexLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            indexLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            indexLabel.widthAnchor.constraint(equalToConstant: 24),
            indexLabel.heightAnchor.constraint(equalToConstant: 24),
            
            iconView.leadingAnchor.constraint(equalTo: indexLabel.trailingAnchor, constant: 10),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 26),
            iconView.heightAnchor.constraint(equalToConstant: 26),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with item: BatchScanItem, index: Int) {
        indexLabel.text = "\(index)"
        titleLabel.text = item.scanResult.title
        iconView.image = item.scanResult.icon?.withRenderingMode(.alwaysOriginal)
        
        // Show a cleaned-up version of the value
        let cleanValue = item.value
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        valueLabel.text = cleanValue
    }
}
