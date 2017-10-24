//
//  MainVC.swift
//  Markdown
//
//  Created by YiGan on 24/10/2017.
//  Copyright © 2017 YiGan. All rights reserved.
//

import Foundation
var infoChanged = false
class MainVC: UIViewController {
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    
    //切换子页面
    var menuItem: MenuItem?{
        didSet{
            
            guard let item = menuItem else {
                return
            }
            
            var identifier: String?
            switch item.menuType {
            case .graphic:
                identifier = "Graphic"
            case .history:
                identifier = "History"
            case .setting:
                identifier = "Setting"
            default:
                break
            }
            
            guard let storyboardId = identifier else {
                return
            }

            //获取相应的故事版
            guard let vc = UIStoryboard(name: storyboardId, bundle: Bundle.main).instantiateInitialViewController() else{
                return
            }
            guard let navigation = navigationController else{
                return
            }
            
            //移除根视图以外的视图
            while navigation.viewControllers.count > 1 {
                navigationController?.viewControllers.removeLast()
            }
            
            //跳转
            navigationController?.show(vc, sender: nil)
        }
    }
    
    //子按钮
    private lazy var subButtonList: [MainRecordButton]? = {
        var list = [MainRecordButton]()
        let buttonImageSize = CGSize(width: 48, height: 48)
        for i in 0..<2{
            let subButton: MainRecordButton = MainRecordButton(index: i, initFrame: self.mainButton.frame)
            subButton.addTarget(self, action: #selector(self.clickSubMenuButton(sender:)), for: .touchUpInside)
            subButton.layer.zPosition = 5
            list.append(subButton)
            self.view.insertSubview(subButton, belowSubview: self.mainButton)
        }
        return list
    }()
    
    /*
    //MARK:主按钮状态
    private var isMainButtonOpen = false{
        didSet{
            
            mainButton.isSelected = isMainButtonOpen
            
            //移除之前动画
            let key = "rotation"
            mainButton.layer.removeAnimation(forKey: key)
            
            //创建按钮动画
            let animation = CABasicAnimation(keyPath: "transform.rotation.z")
            if isMainButtonOpen {
                animation.fromValue = 0
                animation.toValue = Double.pi / 4 + .pi
            }else{
                animation.fromValue = Double.pi / 4 + .pi
                animation.toValue = 0
            }
            animation.duration = 0.2
            animation.repeatCount = 1
            animation.isRemovedOnCompletion = false
            animation.fillMode = kCAFillModeBoth
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            mainButton.layer.add(animation, forKey: key)
            
            //子按钮操作
            self.subButtonList?.forEach{
                button in
                button.setHidden(flag: !isMainButtonOpen)
            }
            
            //动画
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.effectView.isHidden = !self.isMainButtonOpen
            }, completion: {
                complete in
            })
        }
    }
    */
    
    //毛玻璃
    fileprivate lazy var effectView = { () -> UIVisualEffectView in
        let blur: UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let effectView: UIVisualEffectView = UIVisualEffectView(effect: blur)
        effectView.layer.zPosition = 4
        effectView.frame = self.view.bounds
        effectView.isHidden = true
        return effectView
    }()
    
    
    
    
    //MARK:- init ***************************************************************
    override func viewDidLoad() {
        
        config()
        createContents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        //刷新。。。
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        view.layer.cornerRadius = 0
    }
    
    private func config(){
        
        automaticallyAdjustsScrollViewInsets = false
        mainButton.layer.zPosition = 5
    }
    
    private func createContents(){
        
        view.addSubview(effectView)
    }
    
    //MARK:- 跳转到个人设置页
    func performSegueInformation(){
        performSegue(withIdentifier: "information", sender: nil)
    }
    
    //MARK:- 点击子按钮
    @objc private func clickSubMenuButton(sender: UIButton){
        let tag = sender.tag
        
        //关闭子按钮
        showRecord(mainButton)
        
        menuItem = MenuItem.sharedItems[tag]
    }
    
    //MARK:- 点击展开记录列表main button
    @IBAction func showRecord(_ sender: Any) {
        //isMainButtonOpen = !isMainButtonOpen
        
        //跳转到编辑页
        
        guard let editVC = UIStoryboard(name: "Edit", bundle: Bundle.main).instantiateInitialViewController() as? EditVC else {
            return
        }
        navigationController?.show(editVC, sender: nil)
    }
    
    @IBAction func showMenu(_ sender: Any) {
        (navigationController?.parent as! InitVC).hideMenu(false)
    }
}


//MARK:- 触摸事件
extension MainVC{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}
