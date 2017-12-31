//
//  MainVC.swift
//  Markdown
//
//  Created by YiGan on 24/10/2017.
//  Copyright © 2017 YiGan. All rights reserved.
//

import Foundation
var infoChanged = false
class MainVC: UIViewController {
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    //切换子页面
    var menuItem: MenuItem?{
        didSet{
            
            guard let item = menuItem else {
                return
            }
            
            var identifier: String?
            switch item.menuType {
            case .graphic:
                identifier = "Graphic"
            case .history:
                identifier = "History"
            case .setting:
                identifier = "Setting"
            default:
                break
            }
            
            guard let storyboardId = identifier else {
                return
            }

            //获取相应的故事版
            guard let vc = UIStoryboard(name: storyboardId, bundle: Bundle.main).instantiateInitialViewController() else{
                return
            }
            guard let navigation = navigationController else{
                return
            }
            
            //移除根视图以外的视图
            while navigation.viewControllers.count > 1 {
                navigationController?.viewControllers.removeLast()
            }
            
            //跳转
            navigationController?.show(vc, sender: nil)
        }
    }
    
    //子按钮
    private lazy var subButtonList: [MainRecordButton]? = {
        var list = [MainRecordButton]()
        let buttonImageSize = CGSize(width: 48, height: 48)
        for i in 0..<2{
            let subButton: MainRecordButton = MainRecordButton(index: i, initFrame: self.mainButton.frame)
            subButton.addTarget(self, action: #selector(self.clickSubMenuButton(sender:)), for: .touchUpInside)
            subButton.layer.zPosition = 5
            list.append(subButton)
            self.view.insertSubview(subButton, belowSubview: self.mainButton)
        }
        return list
    }()
    
    //毛玻璃
    fileprivate lazy var effectView = { () -> UIVisualEffectView in
        let blur: UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let effectView: UIVisualEffectView = UIVisualEffectView(effect: blur)
        effectView.layer.zPosition = 4
        effectView.frame = self.view.bounds
        effectView.isHidden = true
    
        return effectView
    }()
    
    
    fileprivate var isPastNoteOpen = false
    
    //MARK:- 数据------------------------------------------------------------------------------------------------
    private var noteTypeList = [NoteType]()
    
    //MARK:- init ***************************************************************
    override func viewDidLoad() {
        
        config()
        createContents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //刷新。。。
        updateData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        
        updateData()
    }
    
    //MARK: 更新数据
    fileprivate func updateData(){
        
        let coredataHandler = CoredataHandler.share()
        let unFinishedNotes = coredataHandler.selectNotes(withFetchType: .unFinished)
        noteTypeList = sortAndEnumNotesByDate(withOriginNotes: unFinishedNotes)
        tableView.reloadData()
    }
    
    private func config(){
        
        automaticallyAdjustsScrollViewInsets = false
        mainButton.layer.zPosition = 5
        navigationItem.title = "待办事项"
        mainButton.layer.cornerRadius = mainButton.frame.width / 2
        
        tableView.backgroundColor = .background
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.alwaysBounceVertical = true
        
        //解决重复刷新高度产生错误的bug
        tableView.estimatedRowHeight = .edge8 + 21 + .edge8 + 21 + .edge8
    }
    
    private func createContents(){
        
        view.addSubview(effectView)
    }
    
    //MARK:- 跳转到个人设置页
    func performSegueInformation(){
        performSegue(withIdentifier: "information", sender: nil)
    }
    
    //MARK:- 点击子按钮
    @objc private func clickSubMenuButton(sender: UIButton){
        let tag = sender.tag
        
        //关闭子按钮
        showRecord(mainButton)
        
        menuItem = MenuItem.sharedItems[tag]
    }
    
    //MARK:- 点击添加main button
    @IBAction func showRecord(_ sender: Any) {
        edit(withNote: nil)
    }
    
    //MARK:- 跳转到编辑页
    fileprivate func edit(withNote note: Note?){
        //跳转到编辑页
        guard let editVC = UIStoryboard(name: "Edit", bundle: Bundle.main).instantiateInitialViewController() as? EditVC else {
            return
        }
        editVC.note = note
        navigationController?.show(editVC, sender: nil)
    }
    
    @IBAction func showMenu(_ sender: Any) {
        (navigationController?.parent as! InitVC).hideMenu(false)
    }
}

//MARK:- tableview delegate
extension MainVC: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return noteTypeList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let noteType = noteTypeList[section]
        switch noteType {
        case .past(let pastList):
            return isPastNoteOpen ? pastList.count : 0
        case .today(let todayList):
            return todayList.count
        case .future(let futureList):
            return futureList.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let noteType = noteTypeList[section]
        
        let text = noteType.name()
        let count = noteType.list().count
        let buttonSize = #imageLiteral(resourceName: "header_selected").size
        
        let header = UIView()
        let button = UIButton()//UIButton(frame: buttonFrame)
        switch noteType {
        case .past(let pastNoteList):
            header.frame = CGRect(x: 0, y: 0, width: view_size.width, height: 44 + 64)
            let buttonFrame = CGRect(x: (view_size.width - buttonSize.width) / 2, y: 64 + (44 - buttonSize.height) / 2, width: buttonSize.width, height: buttonSize.height)
            button.frame = buttonFrame
            button.setTitle("查看未处理(\(pastNoteList.count))", for: .selected)
            button.setTitle("查看未处理", for: .normal)
            button.addTarget(self, action: #selector(check(_:)), for: .touchUpInside)
            button.isSelected = !isPastNoteOpen
        default:
            let buttonFrame = CGRect(x: (view_size.width - buttonSize.width) / 2, y: (44 - buttonSize.height) / 2, width: buttonSize.width, height: buttonSize.height)
            header.frame = buttonFrame
            button.frame = buttonFrame
            button.setTitle(text, for: .normal)
        }
        button.setTitleColor(.white, for: .selected)
        button.setTitleColor(.sub, for: .normal)
        button.setBackgroundImage(#imageLiteral(resourceName: "header_normal"), for: .normal)
        button.setBackgroundImage(#imageLiteral(resourceName: "header_selected"), for: .selected)
        //button.setTitleColor(.subWord, for: .normal)
        //        button.setHeaderLabelRadius()
        header.addSubview(button)
        return header
    }
    
    //MARK:- 点击查看
    @objc func check(_ sender: UIButton){
        isPastNoteOpen = sender.isSelected
        sender.isSelected = !sender.isSelected

        let pastNoteList = noteTypeList.filter { (noteType) -> Bool in
            if case NoteType.past(_) = noteType{
                return true
            }
            return false
        }
        
        //判断是否有过去日志
        guard !pastNoteList.isEmpty else {
            return
        }
        
        //取消选中项
        if let selectIndexPath = tableView.indexPathForSelectedRow{
            tableView.deselectRow(at: selectIndexPath, animated: true)
        }
        
        //插入过去日志
        var indexPathList = [IndexPath]()
        for (index, _) in pastNoteList[0].list().enumerated(){
            let indexPath = IndexPath(row: index, section: 0)
            indexPathList.append(indexPath)
        }
        if isPastNoteOpen{    //显示历史提醒
            tableView.insertRows(at: indexPathList, with: .none)
        }else{              //移除历史提醒
            let rowsCount = tableView.numberOfRows(inSection: 0)
            if rowsCount == indexPathList.count{
                tableView.deleteRows(at: indexPathList, with: .none)
            }
        }
    }
    
    //MARK:- 判断当前cell是否被选中
    func isSeleceted(withIndexPath indexPath: IndexPath) -> Bool{
        guard let selectedIndex = tableView.indexPathForSelectedRow else{
            return false
        }
        return selectedIndex == indexPath
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let pastNoteList = noteTypeList.filter { (noteType) -> Bool in
            if case NoteType.past(_) = noteType{
                return true
            }
            return false
        }
        guard !pastNoteList.isEmpty, section == 0 else {
            return 44 //navigation正常高度
        }
        return 44 + 64
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == noteTypeList.count - 1 ? 120 : 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        let row = indexPath.row
        let noteType = noteTypeList[section]
        
        let noteList = noteType.list()
        
        if let cell = tableView.cellForRow(at: indexPath) as? MainCell{
            cell.contentsLabel.numberOfLines = isSeleceted(withIndexPath: indexPath) ? 0 : 1
        }
        
        let originHeight: CGFloat = .edge8 + 21 + .edge8 + 21 + .edge8
        
        if isSeleceted(withIndexPath: indexPath){
            let text = noteList[row].text ?? ""
            let size = CGSize(width: view_size.width - .edge16 * 2 * 2, height: view_size.height)
            let rect = NSString(string: text).boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: UIFont.middle], context: nil)
            
            let resultHeight = .edge8 + 21 + .edge8 + rect.height + .edge8
            let finishedButtonHeight = 30 + .edge8
            return fabs(resultHeight - originHeight) < 20 ? originHeight + finishedButtonHeight : resultHeight + finishedButtonHeight
        }
        return originHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        let noteType = noteTypeList[section]
        let noteList = noteType.list()
        
        let identifier = "cell"
        let note = noteList[row]
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! MainCell
        cell.note = note
        let coredataHandler = CoredataHandler.share()
        
        cell.contentsLabel.numberOfLines = isSeleceted(withIndexPath: indexPath) ? 0 : 1
        //完成回调
        cell.finisheClosure = {
            finished in
            note.isFinished = finished
            guard coredataHandler.commit() else{
                return
            }
            self.updateData()
        }
        //提醒设置回调
        cell.remindClosure = {
            remindFlag in
            note.isNotify = remindFlag
            coredataHandler.commit()
        }
        //编辑回调
        cell.editClosure = {
            self.edit(withNote: note)
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
        let section = indexPath.section
        let row = indexPath.row
        let noteType = noteTypeList[section]
        let noteList = noteType.list()
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
        let section = indexPath.section
        let row = indexPath.row
        let noteType = noteTypeList[section]
        let noteList = noteType.list()
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
        if row == noteList.count - 1{
            isBottomRadius = true
        }
        cell?.setCellRadius(withTop: isTopRadius, withBottom: isBottomRadius)
    }
    
    //取消选中后，处理单个圆角
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        let noteType = noteTypeList[section]
        let noteList = noteType.list()
        let cell = tableView.cellForRow(at: indexPath)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            
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
        }
        tableView.beginUpdates()
        tableView.endUpdates()
        CATransaction.commit()
        
    }
}

//MARK:- 触摸事件
extension MainVC{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}
