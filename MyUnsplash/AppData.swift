//
//  AppData.swift
//  MyUnsplash
//
//  Created by kisoo Um on 2020/11/22.
//  Copyright © 2020 kisoo Um. All rights reserved.
//

import UIKit

class AppData: NSObject {
    static let requestUrlStr = "https://api.unsplash.com"
        
    static let accessKey = "xBZ83EXXOO3Fmfg37cMy9yg2UHgAqxOHKY9zZ3CYS-o"
}
class ReQuestModel{
    enum path {
        case getImages
        case search
    }
}
