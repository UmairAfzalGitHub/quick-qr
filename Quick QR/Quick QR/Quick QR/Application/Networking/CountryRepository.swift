//
//  CountryRepository.swift
//  Quick QR
//
//  Created by Umair Afzal on 01/09/2025.
//

import Foundation

class CountryRepository {
    
    func getCountries() -> [Country] {
        guard let fileUrl = Bundle.main.url(forResource: "Countries", withExtension: "json") else {
            print("File not found.")
            return []
        }
        
        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: fileUrl)
            let countryResponse = try decoder.decode([Country].self, from: data)
            return countryResponse
        } catch {
            print("Error decoding JSON: \(error)")
            return []
        }
    }
    
    func getCities() {
        guard let fileUrl = Bundle.main.url(forResource: "Cities", withExtension: "json") else {
            print("File not found.")
            return
        }
        
        do {
            var countries: [Country] = []
            let jsonData = try Data(contentsOf: fileUrl)
            
            let decoder = JSONDecoder()
            let countryDictionary = try decoder.decode([String: [City]].self, from: jsonData)
            
            // Convert the dictionary into an array of countries
            for (countryCode, cities) in countryDictionary {
                let country = Country(code: countryCode, cities: cities)
                countries.append(country)
            }
            
            // Accessing the countries and their cities
            for country in countries {
                print("Country: \(country.code)")
                for city in country.cities ?? [] {
                    print("\(city.cityName) - \(city.latitude), \(city.longitude), Phone Code: \(city.phoneCode)")
                }
            }
        } catch {
            print("Error decoding JSON: \(error)")
            return
        }
    }
}
