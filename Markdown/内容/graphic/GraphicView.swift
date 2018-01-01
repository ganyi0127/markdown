//
//  GraphicView.swift
//  Markdown
//
//  Created by YiGan on 01/01/2018.
//  Copyright © 2018 YiGan. All rights reserved.
//

import Foundation
class GraphicView: UIView {
    
    var yearTuple: YearTuple?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        var ctx = UIGraphicsGetCurrentContext()
        
        //左边距
        let edgeLeft: CGFloat = .edge16 * 2
        let edgeRight: CGFloat = .edge16 * 2
        let edgeTop: CGFloat = .edge8
        let edgeBottom: CGFloat = .edge16
        
        
        //绘制轴线
        ctx?.move(to: CGPoint(x: edgeLeft, y: bounds.height - edgeBottom))
        ctx?.addLine(to: CGPoint(x: bounds.width - edgeRight, y: bounds.height - edgeBottom))
        
        ctx?.move(to: CGPoint(x: edgeLeft, y: 2))
        ctx?.addLine(to: CGPoint(x: edgeLeft, y: bounds.height - edgeBottom))
        
        ctx?.setStrokeColor(UIColor.white.cgColor)
        ctx?.setLineWidth(1)
        ctx?.setLineCap(.round)
        ctx?.drawPath(using: .stroke)
        
        //文字属性
        let paragraphStyle:NSParagraphStyle = NSParagraphStyle.default.mutableCopy() as! NSParagraphStyle
        let attributes = [
            NSAttributedStringKey.font: UIFont.init(withFontName: .thin, withSize: 12), //文字大小
            NSAttributedStringKey.foregroundColor: UIColor.white,  //文字颜色
            NSAttributedStringKey.paragraphStyle: paragraphStyle]
        
        let size = CGSize(width: .edge16 * 2, height: edgeBottom)
        
        let titleDistanceX = (bounds.width - edgeLeft - edgeRight) / 11
        
        //绘制月份
        for i in 0..<12{
            let x = edgeLeft + CGFloat(i) * titleDistanceX
            
            //绘制4个月份
            if i % 3 != 0{
                continue
            }
            let monthTitle = NSString(string: "\(i + 1)月")
            var monthTitleRect = monthTitle.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
            monthTitleRect.origin = CGPoint(x: x - size.width / 2,
                                            y: bounds.height - .edge16)
            monthTitle.draw(in: monthTitleRect, withAttributes: attributes)
        }
        
        //判断是否有数据
        guard let noteList = yearTuple?.notes, !noteList.isEmpty else {
            return
        }
        
        //获取数据
        var dataList = [(Int, Int)]()
        
        //划分12个月数据
        for i in 0..<12{
            let thisMonthNoteList = noteList.filter({ (note) -> Bool in
                let date = note.beginDate ?? note.date!
                let month = calendar.component(.month, from: date)
                return month == i + 1
            })
            if thisMonthNoteList.isEmpty{
                dataList.append((0, 0))
                continue
            }
            
            let finishedList = thisMonthNoteList.filter{$0.isFinished}
            
            dataList.append((finishedList.count, thisMonthNoteList.count))
        }
        
        //获取最大值
        guard let maxTuple = dataList.max(by: {$0.1 < $1.1}) else{
            return
        }
        
        var maxValue = maxTuple.1
        
        let targetValue: Int
        if maxValue <= 10{
            targetValue = 10
        }else if maxValue < 20{
            targetValue = 18
        }else if maxValue < 30{
            targetValue = 20
        }else if maxValue < 50{
            targetValue = 40
        }else if maxValue < 100{
            targetValue = 80
        }else{
            targetValue = 150
        }
        
        var targetY = (1 - CGFloat(targetValue) / CGFloat(maxValue)) * (bounds.height - .edge16 - edgeTop) + edgeTop
        if targetValue > maxValue{
            targetY = edgeTop
            maxValue = targetValue
        }
        
        //绘制目标线
        ctx?.move(to: CGPoint(x: .edge16 * 2, y: targetY))
        ctx?.addLine(to: CGPoint(x: bounds.width - edgeRight, y: targetY))
        
        ctx?.setLineWidth(1)
        ctx?.setLineDash(phase: 2, lengths: [2, 4])
        ctx?.setStrokeColor(UIColor.white.cgColor)
        ctx?.setLineCap(.round)
        ctx?.drawPath(using: .stroke)
        
        //绘制目标值
        let monthTitle = NSString(string: "\(targetValue)")
        var monthTitleRect = monthTitle.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        monthTitleRect.origin = CGPoint(x: bounds.width - edgeRight, y: targetY - .edge8)
        monthTitle.draw(in: monthTitleRect, withAttributes: attributes)
        
        //绘制数据线(所有)
        drawDataLine(withOnlyFinished: false, data: dataList, maxValue: maxValue, startX: edgeLeft,width: titleDistanceX, context: &ctx)
        
        //绘制数据线(已完成)
        drawDataLine(withOnlyFinished: true, data: dataList, maxValue: maxValue, startX: edgeLeft,width: titleDistanceX, context: &ctx)
        
        
        
    }
    
    //绘制折线
    private func drawDataLine(withOnlyFinished onlyFinished: Bool, data: [(Int, Int)], maxValue: Int, startX: CGFloat, width: CGFloat, context: inout CGContext?){
        for (index, tuple) in data.enumerated(){
            let x = startX + CGFloat(index) * width
            let y = (1 - CGFloat(onlyFinished ? tuple.0 : tuple.1) / CGFloat(maxValue)) * (bounds.height - .edge16 - .edge8) + .edge8
            let point = CGPoint(x: x, y: y)
            if index == 0{
                context?.move(to: point)
            }else{
                context?.addLine(to: point)
            }
            let radius: CGFloat = 1
            let rect = CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)
            context?.addEllipse(in: rect)
            context?.move(to: point)
        }
        context?.setLineWidth(1)
        context?.setLineDash(phase: 0, lengths: [])
        context?.setLineCap(.round)
        context?.setStrokeColor(onlyFinished ? tagColorList[1].cgColor : UIColor.white.cgColor)
        context?.drawPath(using: .stroke)
    }
}
