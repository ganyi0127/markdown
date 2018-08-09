//
//  Navigation+Extension.swift
//  Markdown
//
//  Created by YiGan on 24/10/2017.
//  Copyright © 2017 YiGan. All rights reserved.
//

import Foundation
extension UINavigationController: UINavigationControllerDelegate{
    open override func awakeFromNib() {
        super.awakeFromNib()
        
        

        delegate = self
        
        //初始化存储navigation高度
        if naviagtion_height == nil{
            naviagtion_height = navigationBar.frame.height
        }
        
        //设置title
        navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.middle,
                                             NSAttributedStringKey.foregroundColor: UIColor.white]
        navigationBar.tintColor = .white
        navigationBar.backgroundColor = .sub     //设置背景颜色
        isNavigationBarHidden = true                //默认隐藏导航栏
    }
    
    
    
    //切换界面时调用_手环按钮
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        if viewControllers.count == 1{
            UIView.animate(withDuration: 0.3, animations: {
                self.isNavigationBarHidden = true
            })
        }else{
            UIView.animate(withDuration: 0.3, animations: {
                self.isNavigationBarHidden = false
            })
        }
        
        //判断是否为根视图
//        if viewControllers.count == 1{
//
//        }else{
//            
//            //隐藏tabbar
//            setTabbar(hidden: true)
//
//            setNavigation(hidden: false)
//        }
    }
    
    
    //MARK:- 控制navigation显示与隐藏
    public func setNavigation(hidden flag: Bool){
        var image: UIImage!
        if flag {
            //设置navigation透明
            image = UIImage(named: "resource/navigation_alpha")
            navigationBar.backgroundColor = nil
        }else{
            //设置为不透明
            image = UIImage(named: "resource/navigation_back")?.transfromImage(size: CGSize(width: view_size.width, height: naviagtion_height! + 64))
            navigationBar.backgroundColor = .clear
        }
        navigationBar.setBackgroundImage(image, for: .default)
    }
    
    //MARK:- 控制tabbar显示与隐藏
    public func setTabbar(hidden flag: Bool){
        
        guard var tabbarFrame = tabBarController?.tabBar.frame else {
            return
        }
        
        if flag {
            //隐藏tabbar
            if tabbarFrame.origin.y < view_size.height {
                
                let offsetY:CGFloat = tabbarFrame.height + view_size.width * 0.06
                let duration: TimeInterval = 0.2
                UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
                    self.tabBarController?.tabBar.frame = tabbarFrame.offsetBy(dx: 0, dy: offsetY)
                }, completion: nil)
            }
        }else{
            //显示tabbar
            
            if tabbarFrame.origin.y >= view_size.height{
                
                tabbarFrame.origin.y = view_size.height - tabbarFrame.height
                let duration: TimeInterval = 0.2
                UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
                    self.tabBarController?.tabBar.frame = tabbarFrame
                }, completion: nil)
            }
        }
    }
    
    
    //MARK:- 转场代理实现
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if fromVC.isKind(of: EditVC.self) || toVC.isKind(of: EditVC.self){
            if operation == .push{
                return PushTransition0()
            }else{
                return PopTransition0()
            }
        }
        return nil
    }
}
