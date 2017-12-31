//
//  MainCell.swift
//  Markdown
//
//  Created by YiGan on 25/10/2017.
//  Copyright © 2017 YiGan. All rights reserved.
//

import Foundation
class MainCell: UITableViewCell {
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentsLabel: UILabel!
    @IBOutlet weak var finishedButton: UIButton!            //完成
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var remindButton: UIButton!
    
    var finisheClosure: ((Bool)->())?
    var remindClosure: ((Bool)->())?
    var editClosure: (()->())?
    var deleteClosure: (()->())?
    
    //数据
    var note: Note?{
        didSet{
            guard let n = note else {
                return
            }
            //判断时间是否已过
            var isPast = false
            if let beginDate = n.beginDate{
                let result = beginDate.compare(Date())
                if case result = ComparisonResult.orderedAscending{
                    isPast = true
                }
            }
            
            
            let textColor: UIColor = isPast ? UIColor.init(colorHex: 0xff9323) : .white
            dateLabel.text = n.hasDate ? n.beginDate?.formatString(with: "yyy.M.d") : nil
            dateLabel.textColor = textColor
            timeLabel.text = n.hasTime ? n.beginDate?.formatString(with: "HH:mm") : nil
            timeLabel.textColor = textColor
            contentsLabel.text = n.text
            tagView.isHidden = n.tag == 0
            if n.tag > 0{                
                tagView.backgroundColor = tagColorList[Int(n.tag) - 1]      //0选项为空
            }
        }
    }
    
    //MARK:- init------------------------------------------------------------
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        config()
        
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
    }
    
    private func config(){
        dateLabel.font = .small
        timeLabel.font = .small
        contentsLabel.font = .middle
        
        tagView.layer.cornerRadius = tagView.frame.width / 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        update()
    }
    
    //MARK: 更新
    private func update(){
        backgroundColor = isSelected ? .cardSelected : .card
        if finishedButton != nil{
            finishedButton.isHidden = !isSelected
        }
        if resetButton != nil{
            resetButton.isHidden = !isSelected
        }
        if editButton != nil{
            editButton.isHidden = !isSelected
        }
        if remindButton != nil{
            if isSelected{
                remindButton.isHidden = false
                if let n = note{
                    remindButton.isEnabled = n.beginDate != nil
                }
            }else{
                remindButton.isHidden = true
            }
        }
        
        contentsLabel.textColor = isSelected ? .white : .word
        dateLabel.textColor = isSelected ? .white : .word
        timeLabel.textColor = isSelected ? .white : .word
    }
    
    //MARK:- 完成事项
    @IBAction func finishNote(_ sender: UIButton) {
        finisheClosure?(sender == finishedButton)
    }
    @IBAction func remindNote(_ sender: UIButton) {
        remindButton.isSelected = !remindButton.isSelected
        remindClosure?(remindButton.isSelected)
    }
    @IBAction func editNote(_ sender: UIButton) {
        editClosure?()
    }
    @IBAction func deleteNote(_ sender: UIButton) {
        deleteClosure?()
    }
}
