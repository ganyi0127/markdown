//
//  Color+Extension.swift
//  Markdown
//
//  Created by YiGan on 24/10/2017.
//  Copyright © 2017 YiGan. All rights reserved.
//

import Foundation
extension UIColor{
    convenience init(colorHex hex: UInt, alpha: CGFloat = 1) {
        var aph = alpha
        if aph < 0 {
            aph = 0
        }
        self.init(red: CGFloat((hex & 0xFF0000) >> 16) / 255,
                  green: CGFloat((hex & 0x00FF00) >> 8) / 255,
                  blue: CGFloat(hex & 0x0000FF) / 255,
                  alpha: alpha)
    }
    static let word = UIColor(red: 50 / 255, green: 50 / 255, blue: 50 / 255, alpha: 1)
    static let subWord = UIColor(red: 100 / 255, green: 100 / 255, blue: 100 / 255, alpha: 1)
    static let card = UIColor(colorHex: 0xe0c8b1)
    static let cardSelected = UIColor(colorHex: 0xf5fbbf)
}
