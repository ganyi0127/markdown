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
        let modelURL = Bundle.main.url(forResource: "Markdown", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    //MARK: 设置数据库写入路径 并范围数据库协调器
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.documentDirectoryURL.appendingPathComponent("markdown.sqlite")
        do {
            //避免修改数据库字段后崩溃
            let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
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
    
    // MARK:- 提交修改
    @discardableResult
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
    
    //MARK:- *删* deleteTable by condition
    func delete(_ tableClass: NSManagedObject.Type, byConditionFormat conditionFormat: String) {
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "\(tableClass.self)", in: context)
        request.entity = entityDescription
        
        let predicate = NSPredicate(format: conditionFormat)
        request.predicate = predicate
        
        do{
            let resultList = try context.fetch(request) as! [NSManagedObject]
            if let last = resultList.last{
                context.delete(last)
                guard commit() else{
                    return
                }
            }else{
                fatalError("<Core Data> delete not exist result")
            }
        }catch let error{
            fatalError("<Core Data Delete> \(tableClass) error: \(error)")
        }
    }
}
