//
//  NoteManager.swift
//  Markdown
//
//  Created by YiGan on 17/12/2017.
//  Copyright © 2017 YiGan. All rights reserved.
//

import Foundation

//根据时间划分类型
enum NoteType {
    case past([Note])
    case today([Note])
    case future([Note])
    
    //返回标题
    func name() -> String{
        var result = ""
        switch self {
        case .past(_):
            result = "历史"
        case .today(_):
            result = "今日"
        case .future(_):
            result = "往后"
        }
        return result
    }
    
    //返回数组
    func list() -> [Note]{
        var noteList = [Note]()
        switch self {
        case .past(let list):
            noteList = list
        case .today(let list):
            noteList = list
        case .future(let list):
            noteList = list
        }
        return noteList
    }
}

//根据时间分类
func sortAndEnumNotesByDate(withOriginNotes originNotes: [Note]) -> [NoteType]{
    var resultList = [NoteType]()
    
    let pastList = originNotes.filter { (note) -> Bool in
        guard let beginDate = note.beginDate else{
            return false
        }
        
        var component = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        component.hour = 0
        component.minute = 0
        component.second = 0
        
        let today = calendar.date(from: component) ?? Date()
        let result = beginDate.compare(today)

        return result == ComparisonResult.orderedAscending
    }
    let sortPastList = sortNotesByDate(withOriginNotes: pastList)
    if !sortPastList.isEmpty{
        resultList.append(NoteType.past(sortPastList))
    }
    
    let todayList = originNotes.filter { (note) -> Bool in
        guard let beginDate = note.beginDate else{
            return true
        }
        return beginDate.isToday()
    }
    let todaySortList = sortNotesByDate(withOriginNotes: todayList)
    if !todaySortList.isEmpty{
        resultList.append(NoteType.today(todaySortList))
    }
    
    let futureList = originNotes.filter { (note) -> Bool in
        guard let beginDate = note.beginDate else{
            return false
        }
        
        var component = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        component.hour = 0
        component.minute = 0
        component.second = 0
        
        let today = calendar.date(from: component)?.offset(with: 1) ?? Date().offset(with: 1)
        let result = beginDate.compare(today)
        
        return result == ComparisonResult.orderedDescending
    }
    let futureSortList = sortNotesByDate(withOriginNotes: futureList)
    if !futureSortList.isEmpty{
        resultList.append(NoteType.future(futureSortList))
    }
    return  resultList
}

//根据时间排序
func sortNotesByDate(withOriginNotes originNotes: [Note]) -> [Note]{
    return originNotes.sorted(by: { (note0, note1) -> Bool in
        if let beginDate0 = note0.beginDate, let beginDate1 = note1.beginDate{
            let result = beginDate0.compare(beginDate1)
            if case result = ComparisonResult.orderedAscending{
                return true
            }else{
                return false
            }
        }else if note0.beginDate != nil{
            return true
        }else if note1.beginDate != nil{
            return false
        }else{
            let date0 = note0.date!
            let date1 = note1.date!
            let result = date0.compare(date1)
            switch result{
            case .orderedAscending:
                return true
            default:
                return false
            }
        }
    })
}
