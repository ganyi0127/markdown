//
//  Configure.swift
//  Markdown
//
//  Created by YiGan on 24/10/2017.
//  Copyright © 2017 YiGan. All rights reserved.
//

import Foundation
//MARK:数据库
let coredateHandler = CoredataHandler.share()
//var user: User!

//尺寸
let view_size = UIScreen.main.bounds.size

//navigation高度
var naviagtion_height: CGFloat?

//通用字体、颜色
let font_name = "PingFangTC-Medium"
let font_tiny = UIFont(name: font_name, size: 9)!
let font_small = UIFont(name: font_name, size: 12)!
let font_middle = UIFont(name: font_name, size: 17)!
let font_big = UIFont(name: font_name, size: 24)!
let font_huge = UIFont(name: font_name, size: 44)!

//userDefaults
let userDefaults = UserDefaults.standard

//当前选择的日期
var selectDate = Date()
var preToday = Date()

//文件管理
let fileManager = FileManager.default

//文字颜色
let word_white_color = UIColor.white
let word_light_color = UIColor(colorHex: 0xd9d9d9)                                          //高亮文字颜色
let word_gray_color = UIColor(red: 100 / 255, green: 100 / 255, blue: 100 / 255, alpha: 1)  //灰文字颜色颜色
let word_default_color = UIColor(red: 50 / 255, green: 50 / 255, blue: 50 / 255, alpha: 1)  //文字颜色
let word_editing_color = UIColor.green                                                      //编辑文字

//MARK:- 正则表达式
struct Regex {
    let regex: NSRegularExpression?
    
    init(_ pattern: String) {
        regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    }
    
    func match(input: String) -> Bool {
        if let matches = regex?.matches(in: input, options: [], range: NSMakeRange(0, (input as NSString).length)) {
            return matches.count > 0
        }
        
        return false
    }
}
