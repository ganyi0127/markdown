//
//  EditVCCell.swift
//  Markdown
//
//  Created by YiGan on 30/12/2017.
//  Copyright © 2017 YiGan. All rights reserved.
//

import Foundation
class EditVCCell0: UITableViewCell {
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        config()
    }
    
    private func config(){
        keyLabel.font = UIFont(withFontName: .regular, withSize: 17)
        keyLabel.textColor = .word
        
        valueLabel.font = UIFont(withFontName: .regular, withSize: 14)
        valueLabel.textColor = .subWord
    }
}

class EditVCCell1: UITableViewCell {
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var notifSwitch: UISwitch!
    
    var closure: ((_ isOn: Bool)->())?
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        config()
    }
    
    private func config(){
        keyLabel.font = UIFont.middle
        keyLabel.textColor = .word        
    }

    @IBAction func valueChange(_ sender: UISwitch) {
        closure?(sender.isOn)
    }
}

class EditVCCell2: UITableViewCell {
    
    @IBOutlet weak var keyLabel: UILabel!
    
    var closure: ((_ tag: Int)->())?
    var selectedTag = 0{
        didSet{
            if selectedTag == 0{
                selectedView?.isHidden = true
            }else{
                selectedView?.isHidden = false
                moveSelectedView(toTag: selectedTag)
            }
        }
    }
    
    private lazy var selectedView: UIView? = {
        let length: CGFloat = 8
        let frame = CGRect(x: 0, y: (self.frame.height - length) / 2, width: length, height: length)
        let v = UIView(frame: frame)
        v.layer.cornerRadius = length / 2
        v.backgroundColor = .white
        v.isHidden = true
        return v
    }()
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        config()
    }
    
    private func config(){
        keyLabel.font = .middle
        keyLabel.textColor = .word
        
        let length = frame.height * 0.7
        let count = tagColorList.count
        let originX = frame.width - CGFloat(count) * frame.height - .edge16
        let y = (frame.height - length)  / 2
        for (index, tagColor) in tagColorList.enumerated(){
            let x = originX + CGFloat(index) * frame.height + (frame.height - length) / 2
            let colorViewFrame = CGRect(x: x, y: y, width: length, height: length)
            let colorView = UIView(frame: colorViewFrame)
            colorView.tag = index + 1
            colorView.backgroundColor = tagColor
            colorView.layer.cornerRadius = length / 2
            contentView.insertSubview(colorView, at: 0)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapTag(_:)))
            tap.numberOfTapsRequired = 1
            tap.numberOfTouchesRequired = 1
            colorView.addGestureRecognizer(tap)
        }
        
        //添加选择视图
        contentView.addSubview(selectedView!)
    }
    
    private func moveSelectedView(toTag tag: Int){
        let count = tagColorList.count
        let originX = frame.width - CGFloat(count) * frame.height
        let x = originX + CGFloat(tag - 1) * frame.height + (frame.height - 8) / 2 - .edge16
        let newOrigin = CGPoint(x: x, y: (self.frame.height - 8) / 2)
        
        if selectedView?.frame.origin.x == 0{
            selectedView?.alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.selectedView?.alpha = 1
            })
            selectedView?.frame.origin = newOrigin
        }else{
            UIView.animate(withDuration: 0.3) {
                self.selectedView?.frame.origin = newOrigin
            }
        }
    }
    
    @objc private func tapTag(_ tap: UITapGestureRecognizer){
        guard let colorView = tap.view else{
            return
        }
        
        selectedTag = selectedTag == colorView.tag ? 0 : colorView.tag
        closure?(selectedTag)
    }
}
