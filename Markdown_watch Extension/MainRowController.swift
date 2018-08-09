//
//  MainRowController.swift
//  Markdown
//
//  Created by YiGan on 2018/8/5.
//  Copyright © 2018 YiGan. All rights reserved.
//

import WatchKit
class MainRowController: NSObject {
    @IBOutlet weak var contentLabel: WKInterfaceLabel!
    
    var text: String?{
        didSet{
            contentLabel.setText(text)
        }
    }
    
    
    var tag: Int?{
        didSet{
            
        }
    }
    
//    //标签列表
//    let tagColorList: [UIColor] = [UIColor.init(colorHex: 0xff3b2f),
//                                   UIColor.init(colorHex: 0xff9323),
//                                   UIColor.init(colorHex: 0x007aff),
//                                   UIColor.init(colorHex: 0xcb73e1),
//                                   UIColor.init(colorHex: 0x8f8e94),
//                                   UIColor.init(colorHex: 0x52d865),
//                                   UIColor.init(colorHex: 0xfdce00)]
}
