//
//  GraphicVC.swift
//  Markdown
//
//  Created by YiGan on 24/10/2017.
//  Copyright © 2017 YiGan. All rights reserved.
//

import Foundation
class GraphicVC: UIViewController{
    @IBOutlet weak var tableView: UITableView!
    
    
    private var yearTupleList = [YearTuple]()
    
    //MARK:- init------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config()
        createContents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getYearTupleList { (yearTupleList) in
            self.yearTupleList = yearTupleList
            self.tableView.reloadData()
        }
    }
    
    private func config(){
        navigationItem.title = localized("statistics", comment: "统计")
        
        view.backgroundColor = .background
        
        //解决重复刷新高度产生错误的bug
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
    }
    
    private func createContents(){
        
    }
}

//MARK:- tableview delegate
extension GraphicVC: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return yearTupleList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if tableView.isSeleceted(withIndexPath: indexPath){
//            return 300
//        }
//        return 120
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let yearTuple = yearTupleList[section]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! GraphicVCCell
        cell.yearTuple = yearTuple
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setCellRadius(withTop: true, withBottom: true)
    }
    
    //MARK: 取消选中判断
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell = tableView.cellForRow(at: indexPath)
        let graphicCell = cell as! GraphicVCCell
        
        guard let isSelected = cell?.isSelected else{
            return nil
        }
        
        if isSelected{
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.beginUpdates()
            graphicCell.contentViewHeightConstraint.constant = 0
            graphicCell.labelHeightConstraint.constant = graphicCell.maxLabelHeight
            tableView.endUpdates()
            
            //绘制圆角计算
            cell?.setCellRadius(withTop: true, withBottom: true)
            return nil
        }
        
        return indexPath
    }
    
    //MARK: 选中判断
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        let graphicCell = cell as! GraphicVCCell
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            
        }
        tableView.beginUpdates()
        graphicCell.labelHeightConstraint.constant = 21
        graphicCell.contentViewHeightConstraint.constant = graphicCell.maxHeight
        tableView.endUpdates()
        CATransaction.commit()
        
        //绘制圆角计算
        cell?.setCellRadius(withTop: true, withBottom: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let graphicCell = cell as! GraphicVCCell
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            
            //绘制圆角计算
            cell?.setCellRadius(withTop: true, withBottom: true)
        }
        tableView.beginUpdates()
        graphicCell.contentViewHeightConstraint.constant = 0
        graphicCell.labelHeightConstraint.constant = graphicCell.maxLabelHeight
        tableView.endUpdates()
        CATransaction.commit()
        
    }
}
