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
    @IBOutlet weak var notifyButton: UIButton!          //开启是否提醒
    @IBOutlet weak var notifyDateButton: UIButton!      //提醒时间
    @IBOutlet weak var saveButtonItem: UIBarButtonItem!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var countLabel: UILabel!
    
    private var notifyDate: Date? {
        didSet{
            guard let date = notifyDate else {
                notifyDateButton.setTitle("未设置提醒时间", for: .normal)
                return
            }
            
            notifyDateButton.setTitle(date.formatString(with: "yyy.M.d HH:mm"), for: .normal)
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
            timeButton.setTitle(n.date?.formatString(with: "HH:mm"), for: .normal)
            textView.text = n.text ?? ""
            curCount = n.text?.count ?? 0
            saveButtonItem.title = n.isFinished ? "激活" : "保存"
            notifyDate = n.beginDate
            notifyButton.isSelected = n.isNotify
        }
    }
    
    private func config(){
        curCount = 0
        
        textView.text = ""
        textView.font = .middle
        textView.backgroundColor = .clear
        contentView.backgroundColor = .card
        
        countLabel.isHidden = true
        countLabel.font = .small
        
        let curDate = Date()
        dateButton.setTitle(curDate.formatString(with: "yyy.M.d"), for: .normal)
        timeButton.setTitle(curDate.formatString(with: "HH:mm"), for: .normal)
        
        notifyButton.setTitle("开启提醒", for: .normal)
        notifyButton.setTitle("关闭提醒", for: .selected)
        
        notifyDate = nil
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
    
    //MARK: 开关提醒
    @IBAction func switchNotify(_ sender: UIButton) {
        
        notifyButton.isSelected = !notifyButton.isSelected
        
    }
    
    //MARK: 设置提醒时间
    @IBAction func setNotifyDate(_ sender: UIButton) {
        textView.endEditing(true)
        showSelector(with: .date, closure: {
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
    
    //MARK: 保存当前事项
    @IBAction func save(_ sender: UIBarButtonItem) {
        //判断是否填写内容
        let tempText = textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard !tempText.isEmpty else {
            notif(withTitle: "需填写内容")
            return
        }
        
        //当消息开启的时候需要提供时间
        if notifyButton.isSelected && notifyDate == nil{
            notif(withTitle: "需设置时间")
            return
        }
        
        //添加数据
        let coredataHandler = CoredataHandler.share()
        
        if note == nil{
            note = coredataHandler.insertNote()
        }
        
        note?.beginDate = notifyDate
        note?.isNotify = notifyButton.isSelected
        note?.text = textView.text
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
        
        textViewHeightConstraint.constant = flag ? view_size.height - .edge8 - 30 - .edge8 * 2 - 30 - .edge8 - 256 - 64 : 112
        contentView.setNeedsLayout()
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
