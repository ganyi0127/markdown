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
    @IBOutlet weak var finishedButton: UIButton!
    
    
    var finisheClosure: (()->())?
    var notifClosure: ((Bool)->())?
    
    
    //MARK:- init------------------------------------------------------------
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        config()
        
    }
    override func draw(_ rect: CGRect) {
        setRadius(withTop: true, withBottom: true)
        
    }
    
    private func config(){
        dateLabel.font = .small
        timeLabel.font = .small
        contentsLabel.font = .middle
        
        dateLabel.textColor = .white
        timeLabel.textColor = .white
        contentsLabel.textColor = .gray
        
        backgroundColor = .white
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        UIView.animate(withDuration: 0.5) {
            self.backgroundColor = self.isSelected ? .cardSelected : .card
            if self.finishedButton != nil{                
                self.finishedButton.isHidden = !self.isSelected
            }
        }
    }
    
    //MARK:- 完成事项
    @IBAction func finishNote(_ sender: UIButton) {
        finisheClosure?()
    }
}
