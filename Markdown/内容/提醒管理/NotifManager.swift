//
//  NotifManager.swift
//  Markdown
//
//  Created by YiGan on 01/01/2018.
//  Copyright © 2018 YiGan. All rights reserved.
//

import Foundation

//MARK:- 设置提醒
extension Note{
    func setNotifStatus(withIsOpen isOpen: Bool){
        let notifManager = NotifManager.share()
        notifManager.hasNotif(withNote: self) { (isExisted) in
            if isExisted{
                notifManager.removeNotif(withNote: self)
                if isOpen{
                    notifManager.addNotif(withNote: self)
                }
            }else{
                if isOpen{
                    notifManager.addNotif(withNote: self)
                }
            }
        }
    }
}

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
    
    ///设置提醒状态
    
    ///添加新提醒
    fileprivate func addNotif(withNote note: Note){
        //判断是否可添加提醒
        guard let date = note.beginDate, note.hasDate, note.hasTime, !note.isFinished, !note.isErased else{
            return
        }
        
        let content = UNMutableNotificationContent()
        content.body = note.text ?? ""
        content.sound = UNNotificationSound.default()
        
        //必须大于当前时间判断
        let result = date.compare(Date())
        guard result == .orderedDescending else {
            return
        }
        
        let timeInterval = date.timeIntervalSinceNow
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let identifier = note.objectID.description
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if error != nil{
                UIApplication.shared.keyWindow?.rootViewController?.notif(withTitle: "生成提醒错误")
            }
        }
    }
    
    ///判断是否有创建提醒
    fileprivate func hasNotif(withNote note: Note, closure: @escaping (Bool)->()){
        center.getPendingNotificationRequests { (notificationRequestList) in
            for notificationRequest in notificationRequestList{
                if notificationRequest.identifier == "\(note.objectID)"{
                    closure(true)
                    return
                }
            }
        }
        closure(false)
    }
    
    ///根据ObjectId移除提醒
    fileprivate func removeNotif(withNote note: Note){
        let identifier = "\(note.objectID)"
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
