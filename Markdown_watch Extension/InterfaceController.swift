//
//  InterfaceController.swift
//  Markdown_watch Extension
//
//  Created by YiGan on 2018/8/5.
//  Copyright © 2018 YiGan. All rights reserved.
//

import Foundation
import WatchKit
import WatchConnectivity

class InterfaceController: WKInterfaceController {
    @IBOutlet var table: WKInterfaceTable!
    
    private let session = WCSession.default
    
    private var noteList = [[String: Any]]()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        //设置背景色
    }
    
    override func willActivate() {
        super.willActivate()
        
        //获取数据
        guard WCSession.isSupported() else {
            return
        }
        
        session.delegate = self
        session.activate()
        
        session.sendMessage(["data": 0], replyHandler: { (map) in
            print("<watch>map: \(map)")
        }) { (error) in
            print("<watch>send error: \(error)")
        }
        
        loadRowItems()
        
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    //MARK:- 载入内容
    private func loadRowItems(){

            table.setNumberOfRows(noteList.count, withRowType: "cell")
            
            let count = table.numberOfRows
            for i in 0..<count {
                let dic = noteList[i]
                let text = dic["text"] as? String
                let tag = dic["tag"] as? Int
                
                let cell = table.rowController(at: i) as? MainRowController
                cell?.text = text
                cell?.tag = tag
            }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let row = table.rowController(at: rowIndex) as? MainRowController
        guard let text = row?.text, let tag = row?.tag else {
            return
        }
        
        let data: [String: Any] = ["text": text, "tag": tag]
        pushController(withName: "DetailController", context: data)
    }
}

//MARK:- 通讯协议
extension InterfaceController: WCSessionDelegate{
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {        
        print("<watch>receiveMessageWithReply: \(message)")
        guard let data = message["data"] as? [[String: Any]] else {
            return
        }
        
        noteList = data
        
        loadRowItems()
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        if WCSession.isSupported() {
            let ses = WCSession.default
            ses.delegate = self
            session.activate()
        }
    }
}
