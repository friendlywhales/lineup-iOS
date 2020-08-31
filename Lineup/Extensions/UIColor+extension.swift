//
//  UIColor+extension.swift
//  Lineup
//
//  Created by y8k on 07/12/2018.
//  Copyright © 2018 Lineup. All rights reserved.
//

import UIKit

extension UIColor {

    func alphaComponent(alpha: CGFloat) -> UIColor {
        return self.withAlphaComponent(alpha)
    }

    class var deepPurple: UIColor {
        return UIColor(red: 147.0 / 255.0, green: 71.0 / 255.0, blue: 169.0 / 255.0, alpha: 1.0)
    }

    class var aquaMarine: UIColor {
        return UIColor(red: 57.0 / 255.0, green: 214.0 / 255.0, blue: 166.0 / 255.0, alpha: 1.0)
    }

    class var gunMetal: UIColor {
        return UIColor(red: 72.0 / 255.0, green: 69.0 / 255.0, blue: 86.0 / 255.0, alpha: 1.0)
    }

    class var lightRed: UIColor {
        return UIColor(red: 240.0 / 255.0, green: 61.0 / 255.0, blue: 68.0 / 255.0, alpha: 1.0)
    }

    class var gray51: UIColor {
        return UIColor(white: 51.0 / 255.0, alpha: 1.0)
    }

    class var gray68: UIColor {
        return UIColor(white: 68.0 / 255.0, alpha: 1.0)
    }

    class var gray102: UIColor {
        return UIColor(white: 102.0 / 255.0, alpha: 1.0)
    }

    class var gray136: UIColor {
        return UIColor(white: 136.0 / 255.0, alpha: 1.0)
    }

    class var gray153: UIColor {
        return UIColor(white: 153.0 / 255.0, alpha: 1.0)
    }

    class var gray221: UIColor {
        return UIColor(white: 221.0 / 255.0, alpha: 1.0)
    }
}
