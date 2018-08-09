//
//  GANCalendar.swift
//  Markdown
//
//  Created by YiGan on 14/01/2018.
//  Copyright © 2018 YiGan. All rights reserved.
//

import Foundation
class GANCalendar {
    private static let lunarMonths = ["正", "二", "三", "四", "五", "六", "七", "八", "九", "十", "冬", "腊"]
    private static let lunarDays = ["初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十", "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "廿", "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "卅"]
    
    ///公历转农历(简单处理)
    class func toLunarText(withSolar solar: Date) -> String? {
        let chineseCalendar = Calendar(identifier: .chinese)
        let chineseComponents = chineseCalendar.dateComponents([.month, .day], from: solar)
        
        guard let lunarMonth = chineseComponents.month,
            let lunarDay = chineseComponents.day else{
                return nil
        }
        
        let monthText = lunarMonths[lunarMonth - 1]
        let dayText = lunarDays[lunarDay - 1]
        return monthText + "月" + dayText
    }
}
