//
//  BaseModel.swift
//  封装网络请求
//
//  Created by Xinxibin on 16/5/10.
//  Copyright © 2016年 Xinxibin. All rights reserved.
//

import UIKit

class BaseModel: NSObject {
    
    var avatar:String?
    var msg:String?
    var vtypemeans:String?
    
    
    init(dic:[String:AnyObject]){
        self.avatar = dic["avatar"] as? String
        self.msg = dic["msg"] as? String
        self.vtypemeans = dic["vtypemeans"] as? String
    }
    
}
