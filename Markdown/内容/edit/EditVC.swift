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
    
    //MARK:- init-------------------------
    override func viewDidLoad() {
        config()
        createContents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let n = note {
            dateButton.setTitle(n.date?.formatString(with: "yyy.M.d"), for: .normal)
            timeButton.setTitle(n.date?.formatString(with: "HH:mm"), for: .normal)
            textView.text = n.text ?? ""
            saveButtonItem.title = n.isFinished ? "激活" : "保存"
        }
    }
    
    private func config(){
        textView.text = ""
        
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
        let coredataHandler = CoredataHandler.share()
        
        if note == nil{
            note = coredataHandler.insertNote()
        }
        
        note?.beginDate = notifyDate
        note?.isNotify = notifyButton.isSelected
        note?.text = textView.text
        guard coredataHandler.commit() else{
            print("提交错误")
            return
        }
        
        navigationController?.popViewController(animated: true)
    }
}

extension EditVC: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        textViewHeightConstraint.constant = view_size.height - .edge8 - 30 - .edge8 * 2 - 30 - .edge8 - 256 - 64
        contentView.setNeedsLayout()
        
        hiddenSelector()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {

        textViewHeightConstraint.constant = 88
        contentView.setNeedsLayout()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
