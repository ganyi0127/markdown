//
//  TableView+Extension.swift
//  Markdown
//
//  Created by YiGan on 01/01/2018.
//  Copyright © 2018 YiGan. All rights reserved.
//

import Foundation
extension UITableView{
    //MARK:- 判断当前cell是否被选中
    func isSeleceted(withIndexPath indexPath: IndexPath) -> Bool{
        guard let selectedIndex = self.indexPathForSelectedRow else{
            return false
        }
        return selectedIndex == indexPath
    }
}
