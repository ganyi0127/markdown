//
//  NotifManager.swift
//  Markdown
//
//  Created by YiGan on 01/01/2018.
//  Copyright © 2018 YiGan. All rights reserved.
//

import Foundation

class NotifManager {
    
    let center = UNUserNotificationCenter.current()
    
    //MARK:- init ************************************************************************************
    private static var __once: () = {
        singleton.instance = NotifManager()
    }()
    struct singleton{
        static var instance: NotifManager? = nil
    }
    class func share() -> NotifManager{
        _ = NotifManager.__once
        return singleton.instance!
    }
    
    ///添加新提醒
    func addNotif(withNote note: Note){
        
        guard let date = note.beginDate else{
            return
        }
        
        let content = UNMutableNotificationContent()
        content.body = note.text ?? ""
        content.sound = UNNotificationSound.default()
        
        let timeInterval = date.timeIntervalSinceNow
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let request = UNNotificationRequest(identifier: "1", content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if error != nil{
                UIApplication.shared.keyWindow?.rootViewController?.notif(withTitle: "生成提醒错误")
            }
        }
    }
    
    ///根据ObjectId移除提醒
    func removeNotif(withNote note: Note){
        center.removePendingNotificationRequests(withIdentifiers: [""])
    }
}
