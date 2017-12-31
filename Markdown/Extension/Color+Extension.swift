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
    
    ///主文字
    static let word = UIColor(colorHex: 0x333333)
    ///附文字
    static let subWord = UIColor(colorHex: 0x999999)
    
    
    ///分割线
    static let separator = UIColor.background //UIColor(colorHex: 0xe6e6e6)
    
    ///卡片-正常
    static let card = UIColor(colorHex: 0xffffff)
    ///卡片-选中
    static let cardSelected = UIColor(colorHex: 0x448aca)
    
    ///主色调
    static let main = UIColor(colorHex: 0x448aca)
    ///辅色调
    static let sub = UIColor(colorHex: 0x88abda)
    ///深色调
    static let deep = UIColor(colorHex: 0x0075a9)
    ///home
    static let home = UIColor(colorHex: 0xb6c7c9)
    
    ///背景
    static let background = UIColor(colorHex: 0xc7d2ea)
}
