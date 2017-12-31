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
        let cell: UITableViewCell?
        
        if row == 0{
            cell = tableView.dequeueReusableCell(withIdentifier: "cell0", for: indexPath)
            let cell0 = cell as! MenuCell0
            cell0.label.text = "我偷偷地告诉你，有一个地方叫做稻城，我要和我最心爱的人一起去那里，看蔚蓝的天空，看白色的雪山，看金色的草地，看一场秋天的童话，我要告诉她，如果没有住在你的心里，都是客死他乡，我要告诉她，相爱这件事情，就是永远在一起。"
            cell0.backgroundColor = .home
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath)
            let menuItem = MenuItem.sharedItems[indexPath.row - 1]
            
            let cell1 = cell as! MenuCell1
            cell1.label.text = menuItem.title
            cell1.iconImageView.image = menuItem.image
            cell1.contentView.backgroundColor = menuItem.color
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let initVC = navigationController?.parent as? InitVC
        let row = indexPath.row
        if row == 0{
            //修改个人资料
            //initVC?.setInformation()
            //initVC?.hideMenu(true)            
        }else {         //统计、历史、设置
            //跳转
            initVC?.switchTo(withMenuItem: MenuItem.sharedItems[row - 1])
        }
    }
}
