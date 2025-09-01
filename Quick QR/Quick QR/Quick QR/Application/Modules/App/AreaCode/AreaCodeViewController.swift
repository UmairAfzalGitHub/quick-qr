//
//  AreaCodeViewController.swift
//  Phone Number Tracker
//
//  Created by Umair Afzal on 10/01/2025.
//

import UIKit
import GoogleMobileAds
//import IOS_Helpers

class AreaCodeViewController: BaseViewController,
                              UITableViewDelegate,
                              UITableViewDataSource,
                              CountriesViewControllerDelegate,
                              UITextFieldDelegate,
                              ContactsTableViewCellDelegate {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var areaCodeView: UIView!
    @IBOutlet weak var areaCodeLabel: UILabel!
    @IBOutlet weak var numberBackgroundView: UIView!
    @IBOutlet weak var searchButtonView: UIView!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var bannerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bannerView: BannerView!
    
    let countries = CountryRepository().getCountries()
    var selectedCountry: Country? {
        didSet {
            filteredCities = selectedCountry?.cities
        }
    }
    
    var filteredCities: [City]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBackButton()
        customNavigationBar.setTitle(Strings.Label.areaCode)
        tableView.delegate = self
        tableView.dataSource = self
        
        areaCodeView.layer.cornerRadius = 8
        numberBackgroundView.layer.cornerRadius = 8
        searchButtonView.layer.cornerRadius = 8
        
        selectedCountry = countries.first
        areaCodeLabel.text = selectedCountry?.phoneCode
        let areaCodeTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAreaCodeView))
        areaCodeView.addGestureRecognizer(areaCodeTapGesture)
        
        numberTextField.delegate = self
        numberTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        tableView.register(ContactsTableViewCell.self)
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupBanner(adId: AdMobConfig.banner)
        super.bannerAdView = self.bannerView
        super.viewWillAppear(animated)
        IAPManager.shared.checkSubscriptionStatus { isSubscribed in
            self.bannerView.isHidden = isSubscribed
        }
        
        customNavigationBar.setTitle(Strings.Label.areaCode)
        numberTextField.placeholder = Strings.Label.searchByCity
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCities?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ContactsTableViewCell = tableView.dequeueReusableCell(withIdentifier: String(describing: ContactsTableViewCell.self), for: indexPath) as! ContactsTableViewCell
        cell.delegate = self
        if let city = filteredCities?[indexPath.row] {
            cell.configure(city: city)
        }
        return cell
    }

    // MARK: - Selectors

    @objc func didTapAreaCodeView() {
        let countries = CountryRepository().getCountries()
        let countryViewController = CountriesViewController(dataType: .countries(countries))
        countryViewController.delegate = self
        self.navigationController?.present(countryViewController, animated: true)
    }

    // MARK: - CountriesViewControllerDelegate

    func didSelectCountry(country: Country) {
        areaCodeLabel.text = country.phoneCode
        selectedCountry = country
        tableView.reloadData()
    }

    func didSelectCity(city: City) {}

    func didSelectTimeZone(timeZone: String) {}
    
    // MARK: - Selectors
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let query = textField.text, !query.isEmpty else {
            filteredCities = selectedCountry?.cities
            tableView.reloadData()
            return
        }
        filteredCities = selectedCountry?.cities?.filter { $0.cityName?.lowercased().contains(query.lowercased()) ?? false }
        tableView.reloadData()
    }
    
    // MARK: - ContactsTableViewCellDelegate
    
    func didTapCopy(text: String) {
        UIPasteboard.general.string = text
        showToast(message: Strings.Label.copiedToClipboard)
        view.endEditing(true)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
