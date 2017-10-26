//
//  MenuVC.swift
//  Markdown
//
//  Created by YiGan on 24/10/2017.
//  Copyright © 2017 YiGan. All rights reserved.
//

import Foundation
class MenuVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config()
        createContents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        navigationController?.navigationBar.clipsToBounds = true //不显示导航栏下面的小阴影
    }
    
    private func config(){
        automaticallyAdjustsScrollViewInsets = false
    }
    
    private func createContents(){
        
    }
}

//MARK:- tableview
extension MenuVC: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuItem.sharedItems.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        if row == 0{
            return view.frame.height / 2
        }
        return view.frame.height / 2 / 3
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MenuCell
        
        if row == 0{
            cell.label.text = "home"
            cell.backgroundColor = .gray
        }else{
            let menuItem = MenuItem.sharedItems[indexPath.row - 1]
            
            cell.label.text = menuItem.title
            cell.label.font = font_big
            
            cell.contentView.backgroundColor = menuItem.color
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let initVC = navigationController?.parent as? InitVC
        let row = indexPath.row
        if row == 0{
            //修改个人资料
            //initVC?.setInformation()
            initVC?.hideMenu(true)
        }else {
            //跳转到编辑页面
            initVC?.switchTo(withMenuItem: MenuItem.sharedItems[row - 1])
        }
    }
}
