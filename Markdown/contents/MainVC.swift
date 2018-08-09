//
//  MainVC.swift
//  Markdown
//
//  Created by YiGan on 24/10/2017.
//  Copyright © 2017 YiGan. All rights reserved.
//

import Foundation
import WatchConnectivity

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
            
            if identifier == "Setting" {
                return
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
    fileprivate var isTodayNoteOpen = true
    fileprivate var isFutureNoteOpen = true
    
    fileprivate var mainButtonFrame: CGRect?
    
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
        
        //修改导航栏颜色渐变
        /*
        let gradient = CAGradientLayer()
        let frameAndStatusBar = CGRect(x: 0, y: 0, width: view_size.width, height: 64)
        gradient.frame = frameAndStatusBar
        gradient.colors = [UIColor.background.cgColor, UIColor.card.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 0, y: 0)
        navigationController?.navigationBar.setBackgroundImage(image(fromLayer: gradient), for: .default)
        */
        
        updateData()
    }
    
    //MARK:- 绘制gradient图片
    private func image(fromLayer layer: CALayer) -> UIImage? {
        UIGraphicsBeginImageContext(layer.frame.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage
    }
    
    //MARK: 更新数据
    fileprivate func updateData(){
        
        let coredataHandler = CoredataHandler.share()
        let unFinishedNotes = coredataHandler.selectNotes(withFetchType: .unFinished)
        noteTypeList = sortAndEnumNotesByDate(withOriginNotes: unFinishedNotes)
        tableView.reloadData()
        
        updateToWatch(withNotes: unFinishedNotes)
    }
    
    //MARK:- 给手表发送内容
    private func updateToWatch(withNotes notes: [Note]? = nil){
        var sendNotes = notes
        if sendNotes == nil{
            let coredataHandler = CoredataHandler.share()
            sendNotes = coredataHandler.selectNotes(withFetchType: .unFinished)
        }
        
        //给手表发送消息
        let session = WCSession.default
        if session.isReachable {
            var data = [[String:Any]]()
            for note in sendNotes!{
                data.append(["text": note.text ?? "","tag": note.tag])
            }
            session.sendMessage(["data": data], replyHandler: { (map) in
                
            }) { (error) in
                print("send error: \(error)")
            }
        }
    }
    
    private func config(){
        
        automaticallyAdjustsScrollViewInsets = false
        mainButton.layer.zPosition = 5
        navigationItem.title = "待办事项"
        mainButton.layer.cornerRadius = mainButton.frame.width / 2
        
        if mainButtonFrame == nil {
            mainButtonFrame = mainButton.frame
        }
        
        tableView.backgroundColor = .background
        tableView.alwaysBounceVertical = true
        
        //解决重复刷新高度产生错误的bug
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = .edge8 + 21 + .edge8 + 21 + .edge8
        
        
        //iwatch通讯
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
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
            return isTodayNoteOpen ? todayList.count : 0
        case .future(let futureList):
            return isFutureNoteOpen ? futureList.count : 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let noteType = noteTypeList[section]
        
        let buttonSize = #imageLiteral(resourceName: "header_selected").size
        
        let offsetY: CGFloat = section == 0 ? 64 : 0
        
        let header = UIView()
        header.frame = CGRect(x: 0, y: 0, width: view_size.width, height: 44 + 64)
        let button = UIButton()
        let buttonFrame = CGRect(x: (view_size.width - buttonSize.width) / 2, y: offsetY + (44 - buttonSize.height) / 2, width: buttonSize.width, height: buttonSize.height)
        button.frame = buttonFrame
        switch noteType {
        case .past(let pastNoteList):
            let localizedString = localized("unfinished", comment: "查看未完成")
            button.setTitle(localizedString + "(\(pastNoteList.count))", for: .selected)
            button.setTitle(localizedString, for: .normal)
            button.tag = 0
            button.addTarget(self, action: #selector(check(_:)), for: .touchUpInside)
            button.isSelected = !isPastNoteOpen
        case .today(let todayNoteList):
            let localizedString = localized("today", comment: "今日")
            button.setTitle(localizedString + "(\(todayNoteList.count))", for: .selected)
            button.setTitle(localizedString, for: .normal)
            button.tag = 1
            button.addTarget(self, action: #selector(check(_:)), for: .touchUpInside)
            button.isSelected = !isTodayNoteOpen
        case .future(let futureNoteList):
            let localizedString = localized("will", comment: "往后")
            button.setTitle(localizedString + "(\(futureNoteList.count))", for: .selected)
            button.setTitle(localizedString, for: .normal)
            button.tag = 2
            button.addTarget(self, action: #selector(check(_:)), for: .touchUpInside)
            button.isSelected = !isFutureNoteOpen
        }
        button.setTitleColor(.white, for: .selected)
        button.setTitleColor(.sub, for: .normal)
        button.setBackgroundImage(#imageLiteral(resourceName: "header_normal"), for: .normal)
        button.setBackgroundImage(#imageLiteral(resourceName: "header_selected"), for: .selected)
        header.addSubview(button)
        return header
    }
    
    //MARK:- 点击查看
    @objc func check(_ sender: UIButton){
        
        //取消选中项
        if let selectedIndexPath = tableView.indexPathForSelectedRow{
            tableView.deselectRow(at: selectedIndexPath, animated: true)
            
            CATransaction.begin()
            tableView.beginUpdates()
            CATransaction.setCompletionBlock {
                
                let selectedCell = self.tableView.cellForRow(at: selectedIndexPath)
                let selectedSectionCount = self.tableView.numberOfRows(inSection: selectedIndexPath.section)
                
                //绘制圆角计算
                var isTopRadius = false
                var isBottomRadius = false
                if selectedIndexPath.row == 0 {
                    isTopRadius = true
                }
                if selectedIndexPath.row == selectedSectionCount - 1{
                    isBottomRadius = true
                }
                selectedCell?.setCellRadius(withTop: isTopRadius, withBottom: isBottomRadius)
            }
            tableView.endUpdates()
            CATransaction.commit()
            
        }
        
        //插入删除cell动画
        let animation = UITableViewRowAnimation.fade
        
        //逻辑处理
        let tag = sender.tag
        switch tag {
        case 0:     //未处理
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
            
            
            
            //插入过去日志
            var indexPathList = [IndexPath]()
            for (index, _) in pastNoteList[0].list().enumerated(){
                let indexPath = IndexPath(row: index, section: 0)
                indexPathList.append(indexPath)
            }
            if isPastNoteOpen{    //显示历史提醒
                tableView.insertRows(at: indexPathList, with: animation)
            }else{              //移除历史提醒
                let rowsCount = tableView.numberOfRows(inSection: 0)
                if rowsCount == indexPathList.count{
                    tableView.deleteRows(at: indexPathList, with: animation)
                }
            }
        case 1:     //今日
            isTodayNoteOpen = sender.isSelected
            sender.isSelected = !sender.isSelected
            
            let todayNoteList = noteTypeList.filter { (noteType) -> Bool in
                if case NoteType.today(_) = noteType{
                    return true
                }
                return false
            }
            
            //判断是否有过去日志
            guard !todayNoteList.isEmpty else {
                return
            }
            
            
            
            //判断section
            var section = 0
            if noteTypeList.contains(where: { (notetype) -> Bool in
                switch notetype {
                case .past(_):
                    return true
                default:
                    return false
                }
            }) {
                section = 1
            }
            
            //插入今日日志
            var indexPathList = [IndexPath]()
            for (index, _) in todayNoteList[0].list().enumerated(){
                let indexPath = IndexPath(row: index, section: section)
                indexPathList.append(indexPath)
            }
            if isTodayNoteOpen{    //显示今日提醒
                tableView.insertRows(at: indexPathList, with: animation)
            }else{              //移除今日提醒
                let rowsCount = tableView.numberOfRows(inSection: section)
                if rowsCount == indexPathList.count{
                    tableView.deleteRows(at: indexPathList, with: animation)
                }
            }
        default:        //往后
            isFutureNoteOpen = sender.isSelected
            sender.isSelected = !sender.isSelected
            
            let futureNoteList = noteTypeList.filter { (noteType) -> Bool in
                if case NoteType.future(_) = noteType{
                    return true
                }
                return false
            }
            
            //判断是否有将来日志
            guard !futureNoteList.isEmpty else {
                return
            }
            
            
            
            
            
            //判断section
            var section = 0
            if noteTypeList.count == 3 {
                section = 2
            }else if noteTypeList.count == 2 {
                section = 1
            }
            
            //插入将来日志
            var indexPathList = [IndexPath]()
            for (index, _) in futureNoteList[0].list().enumerated(){
                let indexPath = IndexPath(row: index, section: section)
                indexPathList.append(indexPath)
            }
            if isFutureNoteOpen{    //显示将来提醒
                tableView.insertRows(at: indexPathList, with: animation)
            }else{              //移除将来提醒
                let rowsCount = tableView.numberOfRows(inSection: section)
                if rowsCount == indexPathList.count{
                    tableView.deleteRows(at: indexPathList, with: animation)
                }
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
        return section == 0 ? 44 + 64 : 44
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == noteTypeList.count - 1 ? 120 : 30
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
            note.setNotifStatus(withIsOpen: !finished)
            self.updateData()
        }
        //提醒设置回调
        cell.remindClosure = {
            remindFlag in
            note.isNotify = remindFlag
            guard coredataHandler.commit() else{
                return
            }
            note.setNotifStatus(withIsOpen: remindFlag)
        }
        //编辑回调
        cell.editClosure = {
            self.edit(withNote: note)
        }
        
        if row != 0{
            cell.addTopSeparator()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        let noteType = noteTypeList[section]
        let noteList = noteType.list()
        
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
            CATransaction.begin()
            tableView.beginUpdates()
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
            tableView.endUpdates()
            CATransaction.commit()
            
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
        tableView.beginUpdates()
        CATransaction.setCompletionBlock {
            
        }
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
        tableView.beginUpdates()
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
        tableView.endUpdates()
        CATransaction.commit()
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.3, animations: {
            self.mainButton.frame.origin.y = view_size.height - self.mainButton.frame.height / 4
        })
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        endMainButtonAnimation()
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        endMainButtonAnimation()
    }
    
    private func endMainButtonAnimation() {
        UIView.animate(withDuration: 0.3) {
            self.mainButton.frame = self.mainButtonFrame ?? .zero
        }
    }
    
    //以下作用于排序
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
}

//MARK:- 触摸事件
extension MainVC{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}

//MARK:- 通讯协议
extension MainVC: WCSessionDelegate{
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        updateToWatch()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        //updateToWatch()
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        updateToWatch()
    }
}
