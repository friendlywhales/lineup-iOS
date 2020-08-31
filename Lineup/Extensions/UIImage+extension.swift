//
//  UIImage+extension.swift
//  Lineup
//
//  Created by y8k on 27/02/2019.
//  Copyright © 2019 Lineup. All rights reserved.
//

import UIKit

extension UIImage {
    class func image(from color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)

        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)

        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        context.setFillColor(color.cgColor)
        context.fill(rect)

        let coloredImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return coloredImage
    }
}
