//
//  UnsplashData.swift
//  MyUnsplash
//
//  Created by kisoo Um on 2020/11/19.
//  Copyright © 2020 kisoo Um. All rights reserved.
//

import UIKit

class UnsplashData: NSObject {
    
    var id : String
    var fullUrl : String = ""
    var fullData : Data? = nil
    var thumbUrl : String = ""
    var thumbData : Data? = nil
    
    var regularUrl : String = ""
    var regularData : Data? = nil
    
    init(item : [String : Any]){
        let id : String? = item["id"] as? String
        let ursl :[String : Any]?  = item["urls"] as? [String : Any]
        
        let fullUrl : String? = ursl?["full"] as? String
        let thumbUrl : String? = ursl?["thumb"] as? String
        let regularUrl : String? = ursl?["regular"] as? String
        self.id = id ?? ""
        self.fullUrl = fullUrl ?? ""
        self.thumbUrl = thumbUrl ?? ""
        self.regularUrl = regularUrl ?? ""
    }
    
}
