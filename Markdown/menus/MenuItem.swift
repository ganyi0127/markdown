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
    
    init(withMenuType menuType: MenuType) {
        self.menuType = menuType
        
        switch menuType {
        case .home:
            title = "主页"
            color = .darkGray
        case .graphic:
            title = "统计"
            color = .orange
        case .history:
            title = "历史"
            color = .cyan
        case .setting:
            title = "设置"
            color = .red
        }
    }
}
