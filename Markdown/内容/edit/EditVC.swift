//
//  EditVC.swift
//  Markdown
//
//  Created by YiGan on 24/10/2017.
//  Copyright © 2017 YiGan. All rights reserved.
//

import Foundation
class EditVC: UIViewController {
    @IBOutlet weak var contentView: UIView!             //待办事项底图
    @IBOutlet weak var textView: UITextView!            //待办事项内容
    @IBOutlet weak var dateButton: UIButton!            //待办事项日期
    @IBOutlet weak var timeButton: UIButton!            //待办事项时间
    @IBOutlet weak var saveButtonItem: UIBarButtonItem!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!          //列表
    
    //标签
    private var noteTag = 0
    //提醒开关
    private var isOn = false
    //提醒日期
    private var notifyDate: Date? {
        didSet{
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    //提醒时间
    private var notifyTime: Date? {
        didSet{
            let indexPath = IndexPath(row: 1, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    ///数据模型
    var note: Note?
    
    //内容字符长度
    fileprivate let maxCount = 100
    fileprivate var curCount = 0{
        didSet{
            countLabel.text = "\(curCount)/\(maxCount)"
            countLabel.textColor = curCount == maxCount ? .red : .black
        }
    }
    
    //MARK:- init-------------------------------------------------------------------
    override func viewDidLoad() {
        config()
        createContents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let n = note {
            dateButton.setTitle(n.date?.formatString(with: "yyy.M.d"), for: .normal)
            //timeButton.setTitle(n.date?.formatString(with: "HH:mm"), for: .normal)
            textView.text = n.text ?? ""
            curCount = n.text?.count ?? 0
            saveButtonItem.title = n.isFinished ? "激活" : "保存"
            notifyDate = n.beginDate
            if n.hasTime{
                notifyTime = n.beginDate
            }
            isOn = n.isNotify
            noteTag = Int(n.tag)
            
            tableView.reloadData()
        }
    }
    
    override func back() {
        if textView.isFirstResponder{
            textView.endEditing(true)
        }else{
            super.back()
        }
    }
    
    private func config(){
        curCount = 0
        
        view.backgroundColor = .background
        
        textView.text = ""
        textView.font = .small
        textView.textColor = .word
        textView.backgroundColor = .white
        textView.layer.cornerRadius = .cornerRadius
        contentView.backgroundColor = UIColor.separator
        contentView.setRadius(withTop: true, withBottom: true)
        tableView.backgroundColor = .background
        
        
        countLabel.isHidden = true
        countLabel.font = .small
        
        dateButton.setTitle(nil, for: .normal)
        timeButton.setTitle(nil, for: .normal)
        
        dateButton.setTitleColor(.white, for: .normal)
        timeButton.setTitleColor(.white, for: .normal)
        
        notifyDate = nil
        
        //键盘事件
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notif:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notif:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private func createContents(){
        
    }
    
    //MARK:- 更新布局
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()    
    }
    
    override func viewDidLayoutSubviews() {
        contentView.setRadius(withTop: true, withBottom: true)
    }
    
    //MARK: 设置提醒日期
    func setNotifyDate() {
        textView.endEditing(true)
        showSelector(with: .date, defaultValue: notifyDate, closure: {
            accepted, value in
            
            guard accepted else{
                return
            }
            
            guard let date = value as? Date else{
                return
            }
            
            self.notifyDate = date
        })
    }
    
    //MARK: 设置提醒时间
    func setNotifyTime(){
        textView.endEditing(true)
        showSelector(with: .time, defaultValue: notifyTime) { (accepted, value) in
            guard accepted else{
                return
            }
            
            guard let time = value as? Date else{
                return
            }
            
            self.notifyTime = time
        }
    }
    
    //MARK: 保存当前事项
    @IBAction func save(_ sender: UIBarButtonItem) {
        //判断是否填写内容
        let tempText = textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard !tempText.isEmpty else {
            notif(withTitle: "需填写内容")
            return
        }
        
        //当消息开启的时候需要提供时间
        if isOn && (notifyDate == nil || notifyTime == nil){
            notif(withTitle: "需设置完整日期与时间")
            return
        }
        
        //添加数据
        let coredataHandler = CoredataHandler.share()
        
        if note == nil{
            note = coredataHandler.insertNote()
        }
        
        //合并日期时间
        if let date = notifyDate, let time = notifyTime{
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
            dateComponents.hour = timeComponents.hour
            dateComponents.minute = timeComponents.minute
            if let beginDate = calendar.date(from: dateComponents){
                note?.beginDate = beginDate
            }else{
                note?.beginDate = nil
            }
            note?.hasDate = true
            note?.hasTime = true
        }else if let date = notifyDate {
            note?.beginDate = date
            note?.hasDate = true
            note?.hasTime = false
        }else if let time = notifyTime{
            note?.beginDate = time
            note?.hasDate = false
            note?.hasTime = true
        }else{
            note?.beginDate = nil
            note?.hasDate = false
            note?.hasTime = false
        }
        
        note?.isNotify = isOn
        note?.text = textView.text
        note?.tag = Int32(noteTag)
        guard coredataHandler.commit() else{
            notif(withTitle: "提交错误")
            return
        }
        
        navigationController?.popViewController(animated: true)
    }
}

extension EditVC: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        isTextViewEditing(flag: true)
        hiddenSelector()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {        
        
        isTextViewEditing(flag: false)
    }
    
    private func isTextViewEditing(flag: Bool){
        
        countLabel.isHidden = !flag
        
        //textViewHeightConstraint.constant = flag ? view_size.height - .edge8 - 30 - (.edge8 * 2 - 30) * 0 - .edge8 - 256 - 64 : 112
        //contentView.setNeedsLayout()
    }
    
    //键盘弹出
    @objc func keyboardWillShow(notif:NSNotification){
        let userInfo = notif.userInfo
        
        let keyboardBounds = (userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration = (userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let offset = keyboardBounds.size.height
        let constraint = view_size.height - .edge8 - 30 - (.edge8 * 2 - 30) * 0 - .edge8 - offset - 64
        
        let animations = {
            self.textViewHeightConstraint.constant = constraint
        }
        
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations, completion: nil)
        }else{
            animations()
        }
        
    }
    
    //键盘回收
    @objc func keyboardWillHide(notif:NSNotification){
        let userInfo = notif.userInfo
        
        let duration = (userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let animations = {
            self.textViewHeightConstraint.constant = 112
        }
        
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations, completion: nil)
        }else{
            animations()
        }
    }
    
    
    //设置长度限制与回车接触判定
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //回车==结束
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        
        let textCount = textView.text.count
        
        //判断首行是否为空格，禁止输入
        if textCount == 0 && text.hasPrefix(" ") {
            return false
        }
        
        let selectedCount = range.length
        let replaceCount = text.count
        
        let resultCount = textCount - selectedCount + replaceCount
        guard resultCount <= maxCount else {
            return false
        }
        curCount = resultCount
        return true
    }
}

extension EditVC: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        var isTopFlag = false
        var isBottomFlag = false
        
        let cell: UITableViewCell?
        if row == 0{
            cell = tableView.dequeueReusableCell(withIdentifier: "cell0")
            let cell0 = cell as! EditVCCell0
            if let date = notifyDate{
                cell0.valueLabel.text = date.formatString(with: "yyy-M-d E")
            }else{
                cell0.valueLabel.text = "未选择日期"
            }
            isTopFlag = true
        }else if row == 1{
            cell = tableView.dequeueReusableCell(withIdentifier: "cell0")
            let cell0 = cell as! EditVCCell0
            if let time = notifyTime{
                cell0.valueLabel.text = time.formatString(with: "hh:mm")
            }else{
                cell0.valueLabel.text = "未选择时间"
            }
        }else if row == 2{
            cell = tableView.dequeueReusableCell(withIdentifier: "cell1")
            let cell1 = cell as! EditVCCell1
            cell1.notifSwitch.setOn(isOn, animated: true)
            cell1.closure = {
                isOn in
                if self.notifyDate == nil{
                    if isOn {
                        self.notif(withTitle: "需设置时间")
                        cell1.notifSwitch.setOn(false, animated: true)
                    }
                }else{
                    self.isOn = isOn
                }
            }
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "cell2")
            let cell2 = cell as! EditVCCell2
            cell2.selectedTag = noteTag
            cell2.closure = {
                tag in
                self.noteTag = tag
            }
            
            isBottomFlag = true
        }
        
        if row != 0{
            cell?.addTopSeparator()
        }
        
        cell?.setCellRadius(withTop: isTopFlag, withBottom: isBottomFlag)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.setSelected(false, animated: true)
        
        let row = indexPath.row
        if row == 0{
            setNotifyDate()
        }else if row == 1{
            setNotifyTime()
        }
    }
}
