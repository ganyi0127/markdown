//
//  CoredataHandler.swift
//  Markdown
//
//  Created by YiGan on 24/10/2017.
//  Copyright © 2017 YiGan. All rights reserved.
//

import Foundation
import CoreData
class CoredataHandler {
    
    //coredata-context
    let context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
    
    //日历
    let calendar = Calendar.current
    
    // MARK: Core Data stack
    private lazy var documentDirectoryURL: URL = {
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls.last!
    }()
    
    //MARK: 加载编译后数据模型路径 momd
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "FitFood", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    //MARK: 设置数据库写入路径 并范围数据库协调器
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.documentDirectoryURL.appendingPathComponent("fitfoot.sqlite")
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "初始化数据库失败" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = "载入或创建数据库失败" as AnyObject
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            
            debugPrint("<coredatahandler> 初始化错误 error: \(wrappedError), userinfo: \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    
    
    
    //MARK:- init ************************************************************************************
    private static var __once: () = {
        singleton.instance = CoredataHandler()
    }()
    struct singleton{
        static var instance: CoredataHandler? = nil
    }
    class func share() -> CoredataHandler{
        _ = CoredataHandler.__once
        return singleton.instance!
    }
    
    //MARK:- init
    init() {
        context.persistentStoreCoordinator = persistentStoreCoordinator
    }
    
    //MARK:- 修正日期 范围包含年月日日期
    func translate(_ date: Date, withDayOffset offset: Int = 0) -> Date{
        
        let resultDate = Date(timeInterval: TimeInterval(offset) * 60 * 60 * 24, since: date)
        
        let components = calendar.dateComponents([.year, .month, .day], from: resultDate)
        return calendar.date(from: components)!
    }
    
    // MARK:- 提交修改
    public func commit() -> Bool{
        if context.hasChanges {
            do {
                try context.save()
                return true
            } catch let error {
                debugPrint("<coredatahandler> error context: \(context), error: \(error)")
                abort()
            }
        }
        return false
    }
    
    //MARK:- 根据objectId获取对象
    public func object(with objectId: NSManagedObjectID) -> NSManagedObject?{
        return context.object(with: objectId)
    }
}
