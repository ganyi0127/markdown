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
        noteList = finishedNotes
        tableView.reloadData()
    }
    
    private func config(){
        
        automaticallyAdjustsScrollViewInsets = false
        navigationItem.title = "历史事项"
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
        let identifier = "cell"
        let note = noteList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! MainCell
        cell.dateLabel.text = note.date?.formatString(with: "yyy.M.d")
        cell.timeLabel.text = note.date?.formatString(with: "HH:mm")
        cell.contentsLabel.text = note.text
        cell.contentsLabel.numberOfLines = isSeleceted(withIndexPath: indexPath) ? 0 : 1
        return cell
    }
    
    //MARK: 取消选中判断
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {        
        let cell = tableView.cellForRow(at: indexPath)
        guard let isSelected = cell?.isSelected else{
            return nil
        }
        
        if isSelected{
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.beginUpdates()
            tableView.endUpdates()
            return nil
        }
        return indexPath
    }
    
    //MARK: 选中判断
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    //MARK: 编辑
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteRowAction = UITableViewRowAction(style: .destructive, title: "删除") { (action, indexPath) in
            let note = self.noteList[indexPath.row]
            let coredataHandler = CoredataHandler.share()
            coredataHandler.deleteNote(withNote: note)
            self.updateData()
        }
        return [deleteRowAction]
    }
}
