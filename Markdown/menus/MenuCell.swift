//
//  MenuCell.swift
//  Markdown
//
//  Created by YiGan on 24/10/2017.
//  Copyright © 2017 YiGan. All rights reserved.
//

import Foundation
class MenuCell0: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        config()
    }
    
    private func config(){
        label.textColor = .word
        label.font = .tiny
    }
}

class MenuCell1: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        config()
    }
    
    private func config(){
        label.textColor = .white
        label.font = .small
    }
}
