//
//  UIImage+Extension.swift
//  Quick QR
//

import UIKit

extension UIImage {
    /// Returns a copy of the image with orientation set to `.up` by redrawing into a new context.
    /// This is critical before passing gallery photos to Vision, because large EXIF-rotated images
    /// significantly slow down (or confuse) VNImageRequestHandler on some devices.
    func normalized() -> UIImage {
        guard imageOrientation != .up else { return self }
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
