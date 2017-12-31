//
//  HistoryVC.swift
//  Markdown
//
//  Created by YiGan on 24/10/2017.
//  Copyright © 2017 YiGan. All rights reserved.
//

import Foundation
class HistoryVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- 数据
    private var noteList = [Note]()
    
    
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
        
        updateData()
    }
    
    //MARK: 更新数据
    fileprivate func updateData(){
        
        let coredataHandler = CoredataHandler.share()
        let finishedNotes = coredataHandler.selectNotes(withFetchType: .finished)
        noteList = finishedNotes.sorted(by: { (note0, note1) -> Bool in
            if let beginDate0 = note0.beginDate, let beginDate1 = note1.beginDate{
                let result = beginDate0.compare(beginDate1)
                if case result = ComparisonResult.orderedAscending{
                    return true
                }else{
                    return false
                }
            }else if note0.beginDate != nil{
                return true
            }else if note1.beginDate != nil{
                return false
            }else{
                let date0 = note0.date!
                let date1 = note1.date!
                let result = date0.compare(date1)
                switch result{
                case .orderedAscending:
                    return true
                default:
                    return false
                }
            }
        })
        tableView.reloadData()
    }
    
    private func config(){
        
        automaticallyAdjustsScrollViewInsets = false
        navigationItem.title = "历史事项"
        
        view.backgroundColor = .background
        tableView.rowHeight = UITableViewAutomaticDimension
        
        //解决重复刷新高度产生错误的bug
        tableView.estimatedRowHeight = .edge8 + 21 + .edge8 + 21 + .edge8
    }
    
    private func createContents(){
        
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
}

//MARK:- tableview delegate
extension HistoryVC: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteList.count
    }
    
    func isSeleceted(withIndexPath indexPath: IndexPath) -> Bool{
        guard let selectedIndex = tableView.indexPathForSelectedRow else{
            return false
        }
        return selectedIndex == indexPath
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44   //navigation正常高度
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {        
        if let cell = tableView.cellForRow(at: indexPath) as? MainCell{
            cell.contentsLabel.numberOfLines = isSeleceted(withIndexPath: indexPath) ? 0 : 1
        }
        
        let originHeight: CGFloat = .edge8 + 21 + .edge8 + 21 + .edge8
        
        if isSeleceted(withIndexPath: indexPath){
            let text = noteList[indexPath.row].text ?? ""
            let size = CGSize(width: view_size.width - .edge16 * 2 * 2, height: view_size.height)
            let rect = NSString(string: text).boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: UIFont.middle], context: nil)
            
            let resultHeight = .edge8 + 21 + .edge8 + rect.height + .edge8
            let finishedButtonHeight = 30 + .edge8
            return fabs(resultHeight - originHeight) < 20 ? originHeight + finishedButtonHeight : resultHeight + finishedButtonHeight
        }
        return originHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let identifier = "cell"
        let note = noteList[row]
        let coredataHandler = CoredataHandler.share()
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! MainCell
        cell.tagView.isHidden = true
        cell.dateLabel.text = note.hasDate ? note.date?.formatString(with: "yyy.M.d") : nil
        cell.timeLabel.text = note.hasTime ? note.date?.formatString(with: "HH:mm") : nil
        cell.contentsLabel.text = note.text
        cell.contentsLabel.numberOfLines = isSeleceted(withIndexPath: indexPath) ? 0 : 1
        cell.finisheClosure = {
            finished in
            let note = self.noteList[indexPath.row]
            note.isFinished = finished            
            guard coredataHandler.commit() else{
                return
            }
            self.updateData()
        }
        cell.deleteClosure = {
            let note = self.noteList[indexPath.row]
            note.isErased = true
            guard coredataHandler.commit() else{
                return
            }
            self.updateData()
        }
        
        if row != 0{
            cell.addTopSeparator()
        }
        
        //绘制圆角计算
        var isTopRadius = false
        var isBottomRadius = false
        if row == 0 {
            isTopRadius = true
        }
        if row == noteList.count - 1{
            isBottomRadius = true
        }
        cell.setCellRadius(withTop: isTopRadius, withBottom: isBottomRadius)
        
        return cell
    }
    
    //MARK: 取消选中判断
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let row = indexPath.row
        let cell = tableView.cellForRow(at: indexPath)
        
        guard let isSelected = cell?.isSelected else{
            return nil
        }
        
        if isSelected{
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.beginUpdates()
            tableView.endUpdates()
            
            //绘制圆角计算
            var isTopRadius = false
            var isBottomRadius = false
            if row == 0 {
                isTopRadius = true
            }
            if row == noteList.count - 1{
                isBottomRadius = true
            }
            cell?.setCellRadius(withTop: isTopRadius, withBottom: isBottomRadius)
            return nil
        }
        
        return indexPath
    }
    
    //MARK: 选中判断
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let cell = tableView.cellForRow(at: indexPath)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            
        }
        tableView.beginUpdates()
        tableView.endUpdates()
        CATransaction.commit()
        
        //绘制圆角计算
        var isTopRadius = false
        var isBottomRadius = false
        if row == 0 {
            isTopRadius = true
        }
        if row == self.noteList.count - 1{
            isBottomRadius = true
        }
        cell?.setCellRadius(withTop: isTopRadius, withBottom: isBottomRadius)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let row = indexPath.row

        let cell = tableView.cellForRow(at: indexPath)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            
            //绘制圆角计算
            var isTopRadius = false
            var isBottomRadius = false
            if row == 0 {
                isTopRadius = true
            }
            if row == self.noteList.count - 1{
                isBottomRadius = true
            }
            cell?.setCellRadius(withTop: isTopRadius, withBottom: isBottomRadius)
        }
        tableView.beginUpdates()
        tableView.endUpdates()
        CATransaction.commit()
        
    }
}
