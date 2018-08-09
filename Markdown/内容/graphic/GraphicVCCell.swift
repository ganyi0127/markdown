//
//  GraphicVCCell.swift
//  Markdown
//
//  Created by YiGan on 01/01/2018.
//  Copyright © 2018 YiGan. All rights reserved.
//

import Foundation
class GraphicVCCell: UITableViewCell {
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var labelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var graphicView: GraphicView!
    
    let maxLabelHeight: CGFloat = 96
    let maxHeight = 300 - CGFloat.edge8 * 3 - 21
    
    var yearTuple: YearTuple?{
        didSet{
            //初始化图形数据
            graphicView.yearTuple = yearTuple
            
            //
            guard let tuple = yearTuple else {
                return
            }
            
            //设置年份
            yearLabel.text = "\(tuple.year)" + localized("graphic_year", comment: "年")
            
            
            //设置计数
            let finishedNotes = tuple.notes.filter{$0.isFinished}
            let finishedText = "\(finishedNotes.count)"
            let text = finishedText + "/\(tuple.notes.count)"
            
            let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : UIColor.subWord])
            attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: tagColorList[1], range: NSMakeRange(0, finishedText.count))
            countLabel.attributedText = attributedString

        }
    }
    
    
    private lazy var gradient: CAGradientLayer? = {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.main.cgColor, UIColor.sub.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        gradient.locations = [0, 1]
        gradient.frame = CGRect(x: 0, y: 0, width: view_size.width, height: 300)
        return gradient
    }()
    
    //MARK:- init----------------------------------------------------------------------------
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        config()
        createContents()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        update()
    }
    
    //MARK: 更新
    private func update(){
        let flag = isSelected
        
        //backgroundColor = flag ? .cardSelected : .card
        gradient?.isHidden = !flag
        
        yearLabel.textColor = flag ? .white : .word
        
        if let tuple = yearTuple{
            let finishedNotes = tuple.notes.filter{$0.isFinished}
            let finishedText = "\(finishedNotes.count)"
            let text = finishedText + "/\(tuple.notes.count)"
            let countColor = flag ? UIColor.white : UIColor.subWord
            
            let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor : countColor])
            attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: tagColorList[1], range: NSMakeRange(0, finishedText.count))
            countLabel.attributedText = attributedString
        }
        
        yearLabel.font = flag ? .middle : .big
        countLabel.font = flag ? .middle : .big
        
        if flag{
            delay(0.3, task: {
                self.graphicView.setNeedsDisplay()
            })
        }
    }
    
    private func config(){
        
        backgroundColor = .card
        graphicView.backgroundColor = .clear
        layer.insertSublayer(gradient!, at: 0)
    }
    
    private func createContents(){
        
    }
    
    
}
