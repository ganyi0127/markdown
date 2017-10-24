//
//  MainRecordButton.swift
//  Markdown
//
//  Created by YiGan on 24/10/2017.
//  Copyright © 2017 YiGan. All rights reserved.
//

import Foundation
import UIKit
class MainRecordButton: UIButton {
    //存储原始位置
    private var originFrame: CGRect?
    private var initFrame: CGRect?
    
    //文字
    private var index: Int?
    
    //MARK:- init
    init(index: Int, initFrame: CGRect) {
        originFrame = CGRect(origin: CGPoint(x: view_size.width / 2 - initFrame.width / 2 - initFrame.width + CGFloat(index - 1) * (initFrame.width / 2 + initFrame.width),
                                             y: view_size.height - 49 * 6),
                             size: initFrame.size)
        self.initFrame = initFrame
        super.init(frame: self.initFrame!)
        
        self.index = index
        
        config()
        createContents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func config(){
        
        isEnabled = false
        
        if let i = index {
            //setImage(UIImage(named: "resource/submenuicon/\(i)")?.transfromImage(size: CGSize(width: 48, height: 48)), for: .normal)
            let menuItem = MenuItem.sharedItems[i]
            backgroundColor = .blue
            setTitle(menuItem.title, for: .normal)
            setTitleColor(menuItem.color, for: .normal)
            tag = i
        }
    }
    
    private func createContents(){
        
    }
    
    func setHidden(flag: Bool){
        guard let initFrm = initFrame, let originFrm = originFrame else {
            return
        }
        
        //设置按钮可点状态
        self.isEnabled = !flag
        
        let pos0 = CGPoint(x: initFrm.origin.x + initFrm.width / 2, y: initFrm.origin.y + initFrm.height / 2)
        let pos2 = CGPoint(x: originFrm.origin.x + originFrm.width / 2, y: originFrm.origin.y + originFrm.height / 2)
        let pos1 = CGPoint(x: pos2.x - (pos2.x - pos0.x) * 0.05, y: pos2.y + (pos2.y - pos0.y) * 0.05)
        
        //动画
        let moveAnim = CAKeyframeAnimation(keyPath: "position")
        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        let rotaAnim = CAKeyframeAnimation(keyPath: "transform.rotation")
        let pi = Double.pi * 2 * 2  //两圈
        let groupAnim = CAAnimationGroup()
        if flag{
            
            //隐藏
            if frame.origin.y < initFrm.origin.y {
                moveAnim.values = [NSValue(cgPoint: pos2), NSValue(cgPoint: pos1), NSValue(cgPoint: pos0)]
                moveAnim.keyTimes = [0, 0.2, 1]
            }
            
            opacityAnim.fromValue = 1
            opacityAnim.toValue = 0
            
            rotaAnim.values = [0, pi]
            rotaAnim.keyTimes = [0, 1]
            
            frame = initFrm
        }else{
            
            //显示
            moveAnim.values = [NSValue(cgPoint: pos0), NSValue(cgPoint: pos1), NSValue(cgPoint: pos2)]
            moveAnim.keyTimes = [0, 0.8, 1]
            
            opacityAnim.fromValue = 0
            opacityAnim.toValue = 1
            
            rotaAnim.values = [0, pi * 1.5, pi * 0.8, pi]
            rotaAnim.keyTimes = [0, 0.8, 0.95, 1]
            
            frame = originFrm
        }
        
        groupAnim.animations = [moveAnim, opacityAnim]
        groupAnim.duration = 0.3 + CFTimeInterval(arc4random_uniform(30)) / 100
        groupAnim.isRemovedOnCompletion = true
        groupAnim.fillMode = kCAFillModeBoth
        groupAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        layer.add(groupAnim, forKey: nil)
    }
}
