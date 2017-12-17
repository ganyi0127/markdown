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
    
    /*
    //MARK:主按钮状态
    private var isMainButtonOpen = false{
        didSet{
            
            mainButton.isSelected = isMainButtonOpen
            
            //移除之前动画
            let key = "rotation"
            mainButton.layer.removeAnimation(forKey: key)
            
            //创建按钮动画
            let animation = CABasicAnimation(keyPath: "transform.rotation.z")
            if isMainButtonOpen {
                animation.fromValue = 0
                animation.toValue = Double.pi / 4 + .pi
            }else{
                animation.fromValue = Double.pi / 4 + .pi
                animation.toValue = 0
            }
            animation.duration = 0.2
            animation.repeatCount = 1
            animation.isRemovedOnCompletion = false
            animation.fillMode = kCAFillModeBoth
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            mainButton.layer.add(animation, forKey: key)
            
            //子按钮操作
            self.subButtonList?.forEach{
                button in
                button.setHidden(flag: !isMainButtonOpen)
            }
            
            //动画
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.effectView.isHidden = !self.isMainButtonOpen
            }, completion: {
                complete in
            })
        }
    }
    */
    
    //毛玻璃
    fileprivate lazy var effectView = { () -> UIVisualEffectView in
        let blur: UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let effectView: UIVisualEffectView = UIVisualEffectView(effect: blur)
        effectView.layer.zPosition = 4
        effectView.frame = self.view.bounds
        effectView.isHidden = true
        return effectView
    }()
    
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
        case .past(let futureList):
            return futureList.count
        case .today(let todayList):
            return todayList.count
        case .future(let pastList):
            return pastList.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let noteType = noteTypeList[section]
        
        let text = noteType.name()
        let count = noteType.list().count
        
        let labelFrame = CGRect(x: 0, y: 0, width: view_size.width, height: 44)
        let label = UILabel(frame: labelFrame)
        label.text = text + "\(count)"
        label.textAlignment = .center
        label.textColor = .subWord
        label.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        label.setHeaderLabelRadius()
        return label
    }
    
    //MARK:- 判断当前cell是否被选中
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
        
        cell.contentsLabel.numberOfLines = isSeleceted(withIndexPath: indexPath) ? 0 : 1
        //完成回调
        cell.finisheClosure = {
            finished in
            let coredataHandler = CoredataHandler.share()
            note.isFinished = finished
            guard coredataHandler.commit() else{
                return
            }
            self.updateData()
        }
        //提醒设置回调
        cell.remindClosure = {
            remindFlag in
        }
        //编辑回调
        cell.editClosure = {
            self.edit(withNote: note)
        }
        
        //绘制圆角计算
        var isTopRadius = false
        var isBottomRadius = false
        if row == 0 {
            isTopRadius = true
        }else if row == noteList.count - 1{
            isBottomRadius = true
        }
        cell.setCellRadius(withTop: isTopRadius, withBottom: isBottomRadius)
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
        let section = indexPath.section
        let row = indexPath.row
        let noteType = noteTypeList[section]
        let noteList = noteType.list()
        let cell = tableView.cellForRow(at: indexPath)
        
        tableView.beginUpdates()
        tableView.endUpdates()
        

        //绘制圆角计算
        var isTopRadius = false
        var isBottomRadius = false
        if row == 0 {
            isTopRadius = true
        }else if row == noteList.count - 1{
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
        
        tableView.beginUpdates()
        tableView.endUpdates()
        
        
        //绘制圆角计算
        var isTopRadius = false
        var isBottomRadius = false
        if row == 0 {
            isTopRadius = true
        }else if row == noteList.count - 1{
            isBottomRadius = true
        }
        cell?.setCellRadius(withTop: isTopRadius, withBottom: isBottomRadius)
    }
}

//MARK:- 触摸事件
extension MainVC{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}
