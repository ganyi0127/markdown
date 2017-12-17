//
//  MainCell.swift
//  Markdown
//
//  Created by YiGan on 25/10/2017.
//  Copyright © 2017 YiGan. All rights reserved.
//

import Foundation
class MainCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentsLabel: UILabel!
    @IBOutlet weak var finishedButton: UIButton!            //完成
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var remindButton: UIButton!
    
    var finisheClosure: ((Bool)->())?
    var remindClosure: ((Bool)->())?
    var editClosure: (()->())?
    
    
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
            let textColor: UIColor = isPast ? .red : .white
            dateLabel.text = n.beginDate?.formatString(with: "yyy.M.d")
            dateLabel.textColor = textColor
            timeLabel.text = n.beginDate?.formatString(with: "HH:mm")
            timeLabel.textColor = textColor
            contentsLabel.text = n.text
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
        
        contentsLabel.textColor = .gray
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
            remindButton.isHidden = !isSelected
        }
    }
    
    //MARK:- 完成事项
    @IBAction func finishNote(_ sender: UIButton) {
        finisheClosure?(sender == finishedButton)
    }
    @IBAction func remindNote(_ sender: UIButton) {
        remindClosure?(sender.isSelected)
    }
    @IBAction func editNote(_ sender: UIButton) {
        editClosure?()
    }
}
