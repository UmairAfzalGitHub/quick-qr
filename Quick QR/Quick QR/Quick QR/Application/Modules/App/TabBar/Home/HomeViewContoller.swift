//
//  HomeViewController.swift
//
//  Created by Haider Rathore on 27/08/2025.
//

import UIKit
import BetterSegmentedControl
import GoogleMobileAds

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
    private let nativeAdParentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private var nativeAdView: NativeAdView!
    var nativeAd: GoogleMobileAds.NativeAd?
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let ad = AdManager.shared.getNativeAd() {
            nativeAd = ad
            showGoogleNativeAd(nativeAd: nativeAd)
        } else {
            AdManager.shared.loadNativeAd(adId: AdMobConfig.native, from: self) {[weak self] ad in
                self?.nativeAd = ad
                self?.showGoogleNativeAd(nativeAd: ad)
            }
        }
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
        view.addSubview(nativeAdParentView)
        
        nativeAdParentView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: betterSegmentedControl.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.bottomAnchor.constraint(equalTo: nativeAdParentView.topAnchor, constant: -10),
            
            nativeAdParentView.heightAnchor.constraint(equalToConstant: 240),
            nativeAdParentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nativeAdParentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            nativeAdParentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
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
            header.title = indexPath.section == 0 ? Strings.Label.chooseQrCodeType : Strings.Label.chooseSocialMediaQrCodeType
        } else {
            header.title = Strings.Label.chooseBarCodeType
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
        self.prepareForPushWithoutBackTitle()
        AdManager.shared.showInterstitial(adId: AdMobConfig.interstitial, from: self) {
            self.navigationController?.pushViewController(controller, animated: true)
        }
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
    
    // MARK: - Private Methods:

    private func setAdView(_ view: NativeAdView) {
        // Remove the previous ad view
        if nativeAdView != nil {
            nativeAdView.removeFromSuperview()
        }

        nativeAdView = view
        nativeAdView.tag = 2500
        nativeAdParentView.addSubview(nativeAdView)
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout constraints for positioning the native ad view
        let viewDictionary = ["_nativeAdView": nativeAdView!]
        nativeAdParentView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[_nativeAdView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
        )
        nativeAdParentView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[_nativeAdView]|",
                options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewDictionary)
        )
    }
    
    private func showGoogleNativeAd(nativeAd: GoogleMobileAds.NativeAd?) {
        guard let nativeAd else { return }
        let nibView = Bundle.main.loadNibNamed("OnBoardingNativeAdView", owner: nil, options: nil)?.first
        guard let nativeAdView = nibView as? NativeAdView else { return }
        setAdView(nativeAdView)

        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent

        // Configure optional assets
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        nativeAdView.bodyView?.isHidden = nativeAd.body == nil
        
        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
        nativeAdView.callToActionView?.layer.cornerRadius = 12.0
        
        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
//        nativeAdView.iconView?.isHidden = nativeAd.icon == nil
        
        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
//        nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil
        
        // Disable user interaction on call-to-action view for SDK to handle touches
        nativeAdView.callToActionView?.isUserInteractionEnabled = false
        
        nativeAdView.nativeAd = nativeAd
    }


}
