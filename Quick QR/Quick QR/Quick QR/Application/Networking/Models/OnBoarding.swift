//
//  OnBoarding.swift
//  Quick QR
//
//  Created by Umair Afzal on 26/08/2025.
//

import Foundation
import UIKit

class OnBoarding {
    
    var topImage = UIImage()
    var heading = ""
    var description = ""
    
    init(image: UIImage, heading: String, description: String) {
        topImage = image
        self.heading = heading
        self.description = description
    }
}
