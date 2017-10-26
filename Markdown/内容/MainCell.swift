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
    
    private var gradient: CAGradientLayer?
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        config()
        
        //绘制渐变
        guard gradient == nil else {
            return
        }
        gradient = CAGradientLayer()
        gradient?.frame = CGRect(x: .edge8,
                                 y: .edge8,
                                 width: contentView.bounds.width - .edge8 * 2,
                                 height: contentView.bounds.height - .edge8 * 2)
        gradient?.locations = [0.2, 0.8]
        gradient?.startPoint = CGPoint(x: 0, y: 0)
        gradient?.endPoint = CGPoint(x: 0, y: 1)
        gradient?.colors = [UIColor.card.cgColor, UIColor.card.cgColor]
        gradient?.cornerRadius = .cornerRadius
        gradient?.shadowColor = UIColor.black.cgColor
        layer.insertSublayer(gradient!, at: 0)
        
    }
    override func draw(_ rect: CGRect) {
        UIView.animate(withDuration: 0.5) {
            self.gradient?.frame = CGRect(x: .edge8,
                                          y: .edge8,
                                          width: rect.width - .edge8 * 2,
                                          height: rect.height - .edge8 * 2)
        }
    }
    
    private func config(){
        dateLabel.font = .small
        timeLabel.font = .small
        contentsLabel.font = .middle
        
        dateLabel.textColor = .white
        timeLabel.textColor = .white
        contentsLabel.textColor = .gray
        
        backgroundColor = .clear
    }
}
