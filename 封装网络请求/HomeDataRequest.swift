//
//  HomeDataRequest.swift
//  封装网络请求
//
//  Created by Xinxibin on 16/4/15.
//  Copyright © 2016年 Xinxibin. All rights reserved.
//

import UIKit
  
class HomeDataRequest: MyBaseAPIManager {

    var pageNum = 1
    var pageSize = 10
    var isLoadFirstPage = false
    
    func loadFirstPage() {
        pageNum = 1
        isLoadFirstPage = true
        loadData()
    }

    func loadNextPage() {
        pageNum += 1
        isLoadFirstPage = false
        loadData()
    }
    
    
    override func methodName() -> String {
        return "fm.user.follow"
    }
    
    override func requestParams() -> [String : AnyObject]? {
        let params : [String : AnyObject] = [
            
            "apptoken" : "99a3dffa24cb30c36cae0e3cd08c3e8d",
            "token" : "8d8da3960341456e468a68af2ee4d104",
            "page" : pageNum,
            "do" : "followtrend",
            "pageSize" : pageSize,
            "fid" : "135601920081933452"
        ]
        return params
    }
    
    static func handResult(result:[String:AnyObject]) ->([BaseModel]){
    
        var models : [BaseModel] = []
        if let data = result["data"] as? [String:AnyObject],list = data["list"] as? [AnyObject]{
            
            for item in list {
                if let item = item as? [String:AnyObject] {
                    let model = BaseModel(dic: item)
                    models.append(model)
                }
            }
            
        }
        return models
    }
    
}
