//
//  MenuCell.swift
//  Markdown
//
//  Created by YiGan on 24/10/2017.
//  Copyright © 2017 YiGan. All rights reserved.
//

import Foundation
class MenuCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        config()
    }
    
    private func config(){
        label.textColor = .black
        label.font = .big
    }
}
