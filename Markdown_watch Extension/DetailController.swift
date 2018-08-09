//
//  DetailController.swift
//  Markdown_watch Extension
//
//  Created by YiGan on 2018/8/9.
//  Copyright © 2018 YiGan. All rights reserved.
//

import Foundation
import WatchKit
class DetailController: WKInterfaceController {
    
    @IBOutlet weak var contentLabel: WKInterfaceLabel!
    
    private var text: String?{
        didSet{
            contentLabel.setText(text)
//            contentLabel.sizeToFitHeight()
        }
    }
    
    private var tag: Int?{
        didSet{
            
        }
    }
    
    override func awake(withContext context: Any?) {
        guard let data = context as? [String: Any] else {
            return
        }
        
        text = data["text"] as? String
        tag = data["tag"] as? Int
    }
    
    
    override func willActivate() {
        super.willActivate()
        
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
}
