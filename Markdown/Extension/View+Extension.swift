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
}
