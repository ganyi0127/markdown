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
    func setGraphicRadius(){
        let corner: UIRectCorner = [.topRight, .topLeft, .bottomRight, .bottomLeft]
        
        let roundedRect = CGRect(x: .edge8, y: .edge8, width: bounds.width - .edge8 * 2, height: bounds.height - .edge8 * 2)
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
    
    ///添加顶部分割线
    func addTopSeparator(withColor color: UIColor = .separator){
        let separatorFrame = CGRect(x: 0, y: 0, width: frame.width, height: 1)
        let separator = UIView(frame: separatorFrame)
        separator.backgroundColor = color
        addSubview(separator)
    }
}
