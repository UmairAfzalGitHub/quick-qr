//
//  Language.swift
//  Quick QR
//
//  Created by Umair Afzal on 06/09/2025.
//

import Foundation

// MARK: - Data
class Language {
    var title: String
    var flagImage: String = ""
    var isSelected: Bool = false
    let languageCode: String

    init(title: String = "",
         flagImage: String = "",
         isSelected: Bool = false,
         languageCode : String = ""
    ) {
        self.title = title
        self.flagImage = flagImage
        self.isSelected = isSelected
        self.languageCode = languageCode
    }
}
