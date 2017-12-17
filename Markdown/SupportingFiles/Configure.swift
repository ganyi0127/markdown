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


//userDefaults
let userDefaults = UserDefaults.standard

//日历
let calendar = Calendar.current

//当前选择的日期
var selectDate = Date()
var preToday = Date()

//文件管理
let fileManager = FileManager.default

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
