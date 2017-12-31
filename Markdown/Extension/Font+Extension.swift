//
//  Font+Extension.swift
//  Markdown
//
//  Created by YiGan on 26/10/2017.
//  Copyright © 2017 YiGan. All rights reserved.
//

import Foundation
enum FontName: String{
    case thin = "PingFangTC-Thin"
    case regular = "PingFangTC-Regular"
    case semibold = "PingFangTC-Semibold"
}


extension UIFont {
    //通用字体、颜色
    static let mainName = "PingFangTC-Thin"
    static let tiny = UIFont.init(withFontName: FontName.thin, withSize: 9)
    static let small = UIFont.init(withFontName: FontName.thin, withSize: 12)
    static let middle = UIFont(withFontName: FontName.regular, withSize: 17)
    static let big = UIFont(withFontName: FontName.semibold, withSize: 24)
    static let huge = UIFont(withFontName: FontName.semibold, withSize: 44)
    
    ///自定义初始化
    convenience init(withFontName fontName: FontName, withSize size: CGFloat){
        self.init(name: fontName.rawValue, size: size)!
    }
}
