//
//  UIDevice+Extension.swift
//  Quick QR
//
//  Created by Haider Rathore on 08/10/2025.
//

import UIKit

extension UIDevice {
    func isProDevice() -> Bool {
        let screenHeight = UIScreen.main.bounds.height
        
        // iPhone 12/13/14/15 Pro models have height = 844 points
        // Pro Max models = 926 points, Mini = 812, SE = 667
        return screenHeight >= 840 && screenHeight < 890
    }
}
