//
//  CD+Note.swift
//  Markdown
//
//  Created by YiGan on 25/10/2017.
//  Copyright © 2017 YiGan. All rights reserved.
//

import Foundation
import CoreData
enum FetchType {
    case all
    case finished
    case unFinished
}
extension CoredataHandler{
    
    //插入
    func insertNote() -> Note?{
        
        //判断user是否存在，否则创建
        guard let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as? Note else{
            return nil
        }
        
        note.date = Date()
        
        guard commit() else {
            return nil
        }
        return note
    }
    
    //删除
    func deleteNote(withNote note: NSManagedObject) {
        context.delete(note)
        _ = commit()
    }
    
    //查找所有
    func selectNotes(withFetchType fetchType: FetchType = .all) -> [Note] {
        
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        
        let predicate: NSPredicate
        switch fetchType {
        case .all:
            predicate = NSPredicate(format: "isErased==\(false)")
        case .finished:
            predicate = NSPredicate(format: "isFinished==\(true) AND isErased==\(false)")
            request.predicate = predicate
        case .unFinished:
            predicate = NSPredicate(format: "isFinished==\(false) AND isErased==\(false)")
            request.predicate = predicate
        }
        
        do{
            let resultList = try context.fetch(request)
            return resultList
        }catch let error{
            fatalError("<Core Data> fetch error: \(error)")
        }
        return []
    }
}
