//
//  MenuItem.swift
//  Markdown
//
//  Created by YiGan on 24/10/2017.
//  Copyright © 2017 YiGan. All rights reserved.
//

import Foundation
enum MenuType: String{
    case home = "home"
    case graphic = "graphic"
    case history = "history"
    case setting = "setting"
}
class MenuItem {
    
    static var sharedItems:[MenuItem] {
        var items = [MenuItem]()
        
        items.append(MenuItem(withMenuType: .graphic))
        items.append(MenuItem(withMenuType: .history))
        items.append(MenuItem(withMenuType: .setting))
        
        return items
    }
    
    let title: String
    let color: UIColor
    let menuType: MenuType
    let image: UIImage
    
    init(withMenuType menuType: MenuType) {
        self.menuType = menuType
        
        switch menuType {
        case .home:
            title = localized("menu_main", comment: "主页")
            color = .home
            image = UIImage()
        case .graphic:
            title = localized("menu_statistics", comment: "统计")
            color = .sub
            image = #imageLiteral(resourceName: "graphic")
        case .history:
            title = localized("menu_history", comment: "已完成")
            color = .main
            image = #imageLiteral(resourceName: "history")
        case .setting:
            title = localized("menu_setting", comment: "设置")
            color = .deep
            image = #imageLiteral(resourceName: "setting")
        }
    }
}
