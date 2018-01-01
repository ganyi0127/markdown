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
        return
        //判断是否为根视图
        if viewControllers.count == 1{
            /*
             navigationBar.tintColor = wordColor
             
             if navigationItem.leftBarButtonItem == nil {
             if viewController.isKind(of: StateVC.self){
             if viewController.navigationItem.leftBarButtonItem == nil{
             //                        viewController.navigationItem.leftBarButtonItem = linkBarButton
             //手环状态视图
             let peripheral = PeripheralManager.share().currentPeripheral
             let image = peripheral?.state == CBPeripheralState.connected ? globalBandImageMap[.normal]! : globalBandImageMap[.disConnected]!
             let imageSize = image?.size
             let imageFrame = CGRect(origin: .zero, size: imageSize!)
             let imageView = UIImageView(frame: imageFrame)
             imageView.image = image
             //                        let tap = UITapGestureRecognizer(target: (viewController as! StateVC).topView, action: #selector((viewController as! StateVC).topView.clickCalendar))
             //                        tap.numberOfTapsRequired = 1
             //                        tap.numberOfTouchesRequired = 1
             //                        imageView.addGestureRecognizer(tap)
             if bandItem == nil{
             bandItem = UIBarButtonItem(customView: imageView)
             }
             viewController.navigationItem.leftBarButtonItem = bandItem!
             }
             }
             }
             
             if navigationItem.rightBarButtonItem == nil {
             if viewController.isKind(of: StateVC.self){
             //头像
             let image = UIImage(named: "resource/me/me_head_boy")
             let imageSize = CGSize(width: navigation_height! * 0.98, height: navigation_height! * 0.98)
             let imageFrame = CGRect(origin: .zero, size: imageSize)
             let imageView = UIImageView(frame: imageFrame)
             imageView.image = image
             let maskLayer = CAShapeLayer()
             maskLayer.path = UIBezierPath(ovalIn: imageFrame).cgPath
             imageView.layer.mask = maskLayer
             let tap = UITapGestureRecognizer(target: (viewController as! StateVC).topView, action: #selector((viewController as! StateVC).topView.clickCalendar))
             tap.numberOfTapsRequired = 1
             tap.numberOfTouchesRequired = 1
             imageView.addGestureRecognizer(tap)
             let heardItem = UIBarButtonItem(customView: imageView)
             viewController.navigationItem.rightBarButtonItem = heardItem
             }else if viewController.isKind(of: MeVC.self){
             //个人视图
             let image = UIImage(named: "resource/me/me_setting")
             let imageSize = CGSize(width: navigation_height! * 0.6, height: navigation_height! * 0.6)
             let calenderBarButton = UIBarButtonItem(image: image?.transfromImage(size: imageSize), style: .done, target: viewController, action: #selector(MeVC.clickSetting(sender:)))
             viewController.navigationItem.rightBarButtonItem = calenderBarButton
             }
             }
             
             //设置显示navigation
             if viewController.isKind(of: FunVC.self) || viewController.isKind(of: MeVC.self){
             //地图页面置透明
             setNavigation(hidden: true)
             
             }else{
             //设置为不透明
             setNavigation(hidden: false)
             
             navigationBar.topItem?.title = "" //"FunSport"
             }
             
             //显示tabbar
             setTabbar(hidden: false)
             */
        }else{
            
            //隐藏tabbar
            setTabbar(hidden: true)
            
            setNavigation(hidden: false)
        }
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
