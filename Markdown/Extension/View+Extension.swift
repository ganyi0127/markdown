//
//  View+Extension.swift
//  Markdown
//
//  Created by YiGan on 24/10/2017.
//  Copyright © 2017 YiGan. All rights reserved.
//

import Foundation
extension UIView{
    func viewController() -> UIViewController?{
        var result: AnyObject? = self
        while result != nil {
            result = (result as! UIResponder).next
            if let res = result{
                if res.isKind(of: UIViewController.self) {
                    break
                }
            }else{
                return nil
            }
        }
        
        return result as? UIViewController
    }
    
    //MARK:- 绘制圆角
    func setRadius(withTop topFlag: Bool, withBottom bottomFlag: Bool){
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
        let roundedRect = CGRect(x: .edge8, y: .edge8, width: view_size.width - .edge8 * 2, height: bounds.height - .edge8 * 2)
        let cornerRadii = CGSize(width: .cornerRadius, height: .cornerRadius)
        let path = UIBezierPath(roundedRect: roundedRect, byRoundingCorners: corner, cornerRadii: cornerRadii)
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
}
