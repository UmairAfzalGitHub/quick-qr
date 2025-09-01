import UIKit

protocol CountriesViewControllerDelegate: AnyObject {
    func didSelectCountry(country: Country)
    func didSelectCity(city: City)
    func didSelectTimeZone(timeZone: String)
}

enum CountryPickerType {
    case countries([Country])
    case cities([City])
    case countriesWithoutPhone([Country])
}

enum CountrySortOption {
    case name
    case phoneCode
    
    var title: String {
        switch self {
        case .name:
            return Strings.Label.sortByName
        case .phoneCode:
            return Strings.Label.sortByCode
        }
    }
}

struct Country: Codable {
    var name: String?
    var code: String?
    var phoneCode: String?
    var flag: String?
    var cities: [City]? = []
}

struct City: Codable {
    let cityName: String?
    let latitude: Double?
    let longitude: Double?
    let phoneCode: String?
}


class CountriesViewController: UIViewController,
                               UITableViewDataSource,
                               UITableViewDelegate,
                               UISearchBarDelegate {
    
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    
    private let toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        return toolbar
    }()
    
    private let sortButton: UIButton = {
        let button = UIButton(type: .system)
        if let image = UIImage(named: "sort") ?? UIImage(systemName: "arrow.up.arrow.down") {
            button.setImage(image, for: .normal)
        }
        button.backgroundColor = .appPrimary
        button.tintColor = .white
        button.layer.cornerRadius = 20
        return button
    }()
    
    private var countries: [Country] = []
    private var filteredCountries: [Country] = []

    private var cities: [City] = []
    private var filteredCities: [City] = []
    
    private var currentSortOption: CountrySortOption = .name

    private var dataType: CountryPickerType
    
    var delegate: CountriesViewControllerDelegate?
    
    init(dataType: CountryPickerType) {
        self.dataType = dataType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        setupDataSource()
    }
    
    private func setupDataSource() {
        switch dataType {
        case .countries(let array), .countriesWithoutPhone(let array):
            self.countries = array
            self.filteredCountries = array
            // Sort countries alphabetically by default
            sortCountries(by: .name)
        case .cities(let array):
            self.cities = array
            self.filteredCities = array
        }
        
        let doneButton = UIBarButtonItem(title: Strings.Messages.done, style: .done, target: self, action: #selector(doneButtonTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil) // Flexible space
        toolbar.items = [flexibleSpace, doneButton]
        searchBar.inputAccessoryView = toolbar
    }
    
    private func sortCountries(by option: CountrySortOption) {
        currentSortOption = option
        
        switch option {
        case .name:
            countries.sort { ($0.name ?? "") < ($1.name ?? "") }
        case .phoneCode:
            countries.sort {
                // Extract numeric part from phone code for proper numeric sorting
                let code1 = ($0.phoneCode ?? "").replacingOccurrences(of: "+", with: "")
                let code2 = ($1.phoneCode ?? "").replacingOccurrences(of: "+", with: "")
                let num1 = Int(code1) ?? 0
                let num2 = Int(code2) ?? 0
                return num1 < num2
            }
        }
        
        // Apply the same sort to filtered countries
        if !searchBar.text!.isEmpty {
            applySearchFilter(searchBar.text!)
        } else {
            filteredCountries = countries
        }
        
        tableView.reloadData()
    }
    
    @objc private func sortButtonTapped() {
        // Animate the sort button rotation
        UIView.animate(withDuration: 0.3) {
            self.sortButton.transform = self.sortButton.transform.rotated(by: .pi)
        }
        
        // Toggle between sort options
        let newSortOption: CountrySortOption = (currentSortOption == .name) ? .phoneCode : .name
        sortCountries(by: newSortOption)
    }
    
    private func setupViews() {
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(sortButton)
        
        // Configure search bar
        searchBar.placeholder = Strings.Label.search
        searchBar.delegate = self
        
        // Configure table view
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        // Configure sort button
        sortButton.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
    }
    

    
    private func setupConstraints() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        sortButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Search bar constraints
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Sort button constraints
            sortButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            sortButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            sortButton.widthAnchor.constraint(equalToConstant: 40),
            sortButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Table view constraints
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: -2.0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func doneButtonTapped() {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch dataType {
        case .countries, .countriesWithoutPhone:
            return filteredCountries.count
        case .cities:
            return filteredCities.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        switch dataType {
        case .countries, .countriesWithoutPhone:
            let country = filteredCountries[indexPath.row]
            let flag = country.flag
            let name = country.name
            let code = country.phoneCode
            if case .countries = dataType {
                cell.textLabel?.text = "\(flag.orDash) \(name.orDash) \(code.orDash)"
            } else {
                cell.textLabel?.text = name.orDash
            }
        case .cities:
            let city = filteredCities[indexPath.row]
            cell.textLabel?.text = city.cityName.orDash
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch dataType {
        case .countries, .countriesWithoutPhone:
            let country = filteredCountries[indexPath.row]
            delegate?.didSelectCountry(country: country)
        case .cities:
            let city = filteredCities[indexPath.row]
            delegate?.didSelectCity(city: city)
        }
        self.dismiss(animated: true)
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applySearchFilter(searchText)
        tableView.reloadData()
    }
    
    private func applySearchFilter(_ searchText: String) {
        switch dataType {
        case .countries, .countriesWithoutPhone:
            if searchText.isEmpty {
                filteredCountries = countries
            } else {
                filteredCountries = countries.filter { 
                    ($0.name?.lowercased().contains(searchText.lowercased()) ?? false) || 
                    ($0.phoneCode?.lowercased().contains(searchText.lowercased()) ?? false)
                }
            }
        case .cities:
            if searchText.isEmpty {
                filteredCities = cities
            } else {
                filteredCities = cities.filter { $0.cityName?.lowercased().contains(searchText.lowercased()) ?? false }
            }
        }
    }
}
