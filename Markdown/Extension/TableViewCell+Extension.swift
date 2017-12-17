//
//  TableViewCell+Extension.swift
//  Markdown
//
//  Created by YiGan on 17/12/2017.
//  Copyright © 2017 YiGan. All rights reserved.
//

import Foundation
extension UITableViewCell{
    ///设置左边菜单圆角（未使用）
    func setMenuRadius(){
        let corner: UIRectCorner = [.topRight, .bottomRight]
        
        let roundedRect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        let cornerRadii = CGSize(width: .cornerRadius, height: .cornerRadius)
        let path = UIBezierPath(roundedRect: roundedRect, byRoundingCorners: corner, cornerRadii: cornerRadii)
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
    
    ///设置cell圆角
    func setCellRadius(withTop topFlag: Bool, withBottom bottomFlag: Bool) {
        var corner: UIRectCorner
        if topFlag && bottomFlag{
            corner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
        }else if topFlag{
            corner = [.topLeft, .topRight]
        }else if bottomFlag{
            corner = [.bottomLeft, .bottomRight]
        }else{
            corner = []
        }
        let roundedRect = CGRect(x: .edge8, y: 0, width: bounds.width - .edge8 * 2, height: bounds.height)
        let cornerRadii = CGSize(width: .cornerRadius, height: .cornerRadius)
        let path = UIBezierPath(roundedRect: roundedRect, byRoundingCorners: corner, cornerRadii: cornerRadii)
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
}
