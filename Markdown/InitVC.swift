//
//  ViewController.swift
//  Markdown
//
//  Created by YiGan on 24/10/2017.
//  Copyright © 2017 YiGan. All rights reserved.
//

import UIKit
class InitVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var menuContainerView: UIView!
    @IBOutlet weak var mainContainerView: UIView!
    
    
    fileprivate var menuVC: MenuVC?
    fileprivate var mainVC: MainVC?
    
    fileprivate var progress:CGFloat?
    
    //主页类型
    var menuItem: MenuItem?{
        didSet{
            mainVC?.menuItem = menuItem
        }
    }
    
    //毛玻璃
    fileprivate lazy var effectView = { () -> UIVisualEffectView in
        let blur: UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let effectView: UIVisualEffectView = UIVisualEffectView(effect: blur)
        effectView.frame = CGRect(x: self.menuContainerView.bounds.width, y: 0, width: view_size.width, height: view_size.height)
        return effectView
    }()
    
    private var isMenuHidden: Bool = true{
        didSet{
            
        }
    }
    
    //MARK:- init*****************************************************************
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config()
        createContents()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigation = segue.destination as! UINavigationController
        
        if segue.identifier == "menu"{
            menuVC = navigation.topViewController as? MenuVC
        }else if segue.identifier == "main"{
            mainVC = navigation.topViewController as? MainVC
        }
    }
    
    private func config(){
        scrollView.layer.cornerRadius = .cornerRadius
        
        menuContainerView.layer.anchorPoint = CGPoint(x: 1, y: 0.5)
        hideMenu(true)
        
        //初始化数据库        
    }
    
    private func createContents(){
        
        scrollView.addSubview(effectView)
    }
    
    //MARK:- 个人页面
    func setInformation(){
        hideMenu(true)
        mainVC?.performSegueInformation()
    }
    
    //MARK:- 跳转页面
    func switchTo(withMenuItem menuItem: MenuItem){
        hideMenu(true)
        
        self.menuItem = menuItem
    }
    
    //MARK:- 隐藏菜单
    func hideMenu(_ hidden: Bool){
        isMenuHidden = hidden
        
        let menuOff = menuContainerView.bounds.width
        scrollView.setContentOffset(hidden ? CGPoint(x: menuOff, y: 0) : .zero, animated: true)
    }
}

extension InitVC: UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let multipier = 1 / menuContainerView.bounds.width
        progress = 1 - (scrollView.contentOffset.x) * multipier
        effectView.alpha = progress!
        menuContainerView.layer.transform = menuTransformForPercent(progress!)
        menuContainerView.alpha = progress!
        scrollView.isPagingEnabled = scrollView.contentOffset.x < (scrollView.contentSize.width - scrollView.frame.width)
    }
    
    
    func menuTransformForPercent(_ percent: CGFloat) -> CATransform3D {
        var identity = CATransform3DIdentity
        identity.m34 = -1 / 1000   //1 / [camera distance]
        let remainingPercent = 1 - percent
        let angle = -remainingPercent * .pi / 2
        let rotationTransform = CATransform3DRotate(identity, angle, 0, 1, 0)
        let translationTransform = CATransform3DMakeTranslation(menuContainerView.bounds.width / 2 , 0, 0)
        
        return CATransform3DConcat(rotationTransform, translationTransform)
    }
}
