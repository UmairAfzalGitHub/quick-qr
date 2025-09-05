//
//  HomeViewController.swift
//
//  Created by Haider Rathore on 27/08/2025.
//

import UIKit
import BetterSegmentedControl

// MARK: - HomeViewController
class HomeViewController: UIViewController {
    
    private let betterSegmentedControl: BetterSegmentedControl = {
        let control = BetterSegmentedControl(
            frame: CGRect.zero,
            segments: LabelSegment.segments(withTitles: [Strings.Label.qrCode, Strings.Label.barCode],
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
    
    private var collectionView: UICollectionView!
    
    // Track current segment state
    private var isQRCodeSelected: Bool {
        return betterSegmentedControl.index == 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        title = "Choose Type"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.textPrimary,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
    }
    
    private func setupUI() {
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
        
        // Setup CollectionView
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 20
        layout.headerReferenceSize = CGSize(width: view.frame.width, height: 40)
        layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 20, right: 16)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(QRTypeCell.self, forCellWithReuseIdentifier: QRTypeCell.identifier)
        collectionView.register(HomeHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: HomeHeaderView.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: betterSegmentedControl.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func segmentChanged(_ sender: BetterSegmentedControl) {
        // Reload collection view when segment changes
        collectionView.reloadData()
    }
}

// MARK: - CollectionView DataSource + Delegate
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return isQRCodeSelected ? 2 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isQRCodeSelected {
            return section == 0 ? QRCodeType.allCases.count : SocialQRCodeType.allCases.count
        } else {
            return BarCodeType.allCases.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: QRTypeCell.identifier, for: indexPath) as? QRTypeCell else {
            return UICollectionViewCell()
        }
        
        if isQRCodeSelected {
            if indexPath.section == 0 {
                let type = QRCodeType.allCases[indexPath.item]
                cell.configure(title: type.title, icon: type.icon)
            } else {
                let type = SocialQRCodeType.allCases[indexPath.item]
                cell.configure(title: type.title, icon: type.icon)
            }
        } else {
            let type = BarCodeType.allCases[indexPath.item]
            cell.configure(title: type.title, icon: type.icon)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: HomeHeaderView.identifier, for: indexPath) as? HomeHeaderView else {
            return UICollectionReusableView()
        }
        
        if isQRCodeSelected {
            header.title = indexPath.section == 0 ? "Choose QR Code Type" : "Choose Social Media QR Code Type"
        } else {
            header.title = "Choose Bar Code Type"
        }
        return header
    }
    
    // MARK: - Cell Selection
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let controller = CodeGeneratorViewController()

        if isQRCodeSelected {
            if indexPath.section == 0 {
                let type = QRCodeType.allCases[indexPath.item]
                controller.currentCodeType = type
            } else {
                let type = SocialQRCodeType.allCases[indexPath.item]
                controller.currentCodeType = type
            }
        } else {
            let type = BarCodeType.allCases[indexPath.item]
            controller.currentCodeType = type
        }
        
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // Adjust cell size to fit 4 per row
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing: CGFloat = 16 * 3 + 16 * 2 // (3 interitem gaps + left+right insets)
        let availableWidth = collectionView.bounds.width - totalSpacing
        let width = availableWidth / 4
        return CGSize(width: width, height: 90) // 60 box + 6 gap + label
    }
}
