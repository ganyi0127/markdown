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
        guard let beginDate = note.beginDate, note.hasDate else{
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
        guard let beginDate = note.beginDate, note.hasDate else{
            return true
        }
        return beginDate.isToday()
    }
    let todaySortList = sortNotesByDate(withOriginNotes: todayList)
    if !todaySortList.isEmpty{
        resultList.append(NoteType.today(todaySortList))
    }
    
    let futureList = originNotes.filter { (note) -> Bool in
        guard let beginDate = note.beginDate, note.hasDate else{
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

typealias YearTuple = (year: Int, notes: [Note])

///根据年份分类
func getYearTupleList(closure: @escaping ([YearTuple])->()) {
    DispatchQueue.global().async {
        let dataHandler = CoredataHandler.share()
        let noteList = dataHandler.selectNotes()
        //升序
        let sortedNoteList = noteList.sorted { (note0, note1) -> Bool in
            let noteDate0 = note0.beginDate ?? note0.date!
            let noteDate1 = note1.beginDate ?? note1.date!
            let result = noteDate0.compare(noteDate1)
            if result == ComparisonResult.orderedAscending{
                return true
            }
            return false
        }
        guard let firstNote = sortedNoteList.first,
            let lastNote = sortedNoteList.last else{
                DispatchQueue.main.async {
                    closure([])
                }
                return
        }
        
        let firstDate = firstNote.beginDate ?? firstNote.date!
        let firstYear = calendar.component(.year, from: firstDate)
        let lastDate = lastNote.beginDate ?? lastNote.date!
        let lastYear = calendar.component(.year, from: lastDate)
        
        var resultList = [YearTuple]()
        for year in firstYear...lastYear{
            let thisYearNoteList = sortedNoteList.filter({ (note) -> Bool in
                let date = note.beginDate ?? note.date!
                let y = calendar.component(.year, from: date)
                return y == year
            })
            if !thisYearNoteList.isEmpty{
                resultList.append((year: year, notes: thisYearNoteList))
            }
        }
        DispatchQueue.main.async {
            closure(resultList)
        }
    }
}

//根据时间排序
private func sortNotesByDate(withOriginNotes originNotes: [Note]) -> [Note]{
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
