//
//  Label+Extension.swift
//  Markdown
//
//  Created by YiGan on 17/12/2017.
//  Copyright © 2017 YiGan. All rights reserved.
//

import Foundation
extension UILabel{
    ///设置label圆角
    func setHeaderLabelRadius() {
        let corner: UIRectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
        let labelWidth = view_size.width / 3
        
        let roundedRect = CGRect(x: (view_size.width - labelWidth) / 2, y: .edge8, width: labelWidth, height: bounds.height - .edge8 * 2)
        let cornerRadii = CGSize(width: .cornerRadius, height: .cornerRadius)
        let path = UIBezierPath(roundedRect: roundedRect, byRoundingCorners: corner, cornerRadii: cornerRadii)
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
}
