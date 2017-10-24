//
//  EditVC.swift
//  Markdown
//
//  Created by YiGan on 24/10/2017.
//  Copyright © 2017 YiGan. All rights reserved.
//

import Foundation
class EditVC: UIViewController {
    @IBOutlet weak var textView: UITextView!            //待办事项内容
    @IBOutlet weak var dateButton: UIButton!            //待办事项日期
    @IBOutlet weak var timeButton: UIButton!            //待办事项时间
    @IBOutlet weak var notifyButton: UIButton!          //开启是否提醒
    
    
    //MARK:- init-------------------------
    override func viewDidLoad() {
        config()
        createContents()
    }
    
    private func config(){
        
    }
    
    private func createContents(){
        
    }
}

extension EditVC: UITextViewDelegate{
    
}
