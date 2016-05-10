//
//  MyBaseAPManager.swift
//  封装网络请求
//
//  Created by Xinxibin on 16/4/15.
//  Copyright © 2016年 Xinxibin. All rights reserved.
//

import Foundation
import Alamofire

protocol FMBaseAPIManagerCallBack: class {
    func managerApiCallBackSuccess(manager: MyBaseAPIManager, result: [String: AnyObject])
    func managerApiCallBackFailed(manager: MyBaseAPIManager, errorInfo: String)
}


class MyBaseAPIManager {
    weak var callBack: FMBaseAPIManagerCallBack?
    
    var request:Request?
    
    /// 是否是网络错误
    var isNetError = false
    
    /// 用于区分多个请求，绝大部分情况用不到
    var tag = 0
    
    /// 回调信息
    var isLoading = false
    var rawData: NSData?
    var resultDic = [String:AnyObject]()
    // 回调错误提示
//    var errorInfo = HudInfoString.netErrorInfo
    
    private var startTime : NSDate?
    private var spendTime : NSTimeInterval = 0.0
    
    /**
     api接口
     */
    func methodName() -> String {
        return ""
    }
    
    /**
     请求类型，默认Post请求
     */
    func reqeustType() -> String {
        return "POST"
    }
    
    /**
     默认错误信息
     */
    func errorMessage() -> String? {
        return nil
    }
    
    /**
     请求参数
     */
    func requestParams() -> [String:AnyObject]? {
        return nil
    }
    
    /*!
     上传文件
     
     - returns: 文件名和数据
     */
    func uploadFile() -> (key:String,data:NSData)? {
        return nil
    }
    
    /**
     开始加载数据
     */
    func loadData() {
        startTime = NSDate()
        fire()
    }
    
    /**
     取消请求
     */
    func cancelRequest() {
        request?.cancel()
    }
    
    /**
     开始请求
     */
    private func fire() {
        // 构造请求基本参
        
        var paramsDic:[String:AnyObject] = [
            "apptoken": "",
            "version" : "1.0",
            "method"  : methodName(),
            "os"      : "ios"
        ]
        
        if let par = requestParams() {
            paramsDic.update(par)
        }
        
        
        let logStr = String(stringInterpolation:
            String(self.self), " Send Request With Param :\n","params:\(paramsDic.description)\n"
        )
        print("\(logStr)")
        
        
        let urlRequest = urlRequestWithComponents("http://api.fengmi.tv", parameters: paramsDic, imageData: uploadFile())
        
        Alamofire.upload(urlRequest.0, data: urlRequest.1)
            .responseJSON(completionHandler: { (response) in
                self.spendTime = NSDate().timeIntervalSinceDate(self.startTime!)
                switch response.result {
                case .Success:
                    if let responseObject = response.result.value as? [String:AnyObject] {
                        
                        let logStr = String(stringInterpolation:
                            String(self.self), " Received Response :\n","params:\(responseObject.description)\n"
                        )
                        print("\(logStr)")
                        
                        if let statue = responseObject["status"] as? Int where statue == 200 {
                            self.resultDic = responseObject
                            self.callBack?.managerApiCallBackSuccess(self, result: self.resultDic)
                        } else {
                            if let error = responseObject["error_msg"] as? String {
//                                self.errorInfo = error
                                self.callBack?.managerApiCallBackFailed(self, errorInfo: error)
                            } else {
//                                self.errorInfo = "服务器未返回错误信息"
                                self.callBack?.managerApiCallBackFailed(self, errorInfo: "服务器未返回错误信息")
                            }
                        }
                    } else {
//                        self.errorInfo = "返回数据异常"
                        self.callBack?.managerApiCallBackFailed(self, errorInfo: "服务器未返回错误信息")
                    }
                case .Failure:
                    self.isNetError = true
                    self.callBack?.managerApiCallBackFailed(self, errorInfo: "")
                }
                
            })
    }
    
    
    // 上床图片 转换图片
    private func urlRequestWithComponents(urlString:String, parameters:[String: AnyObject], imageData:(key:String,data:NSData)?) -> (URLRequestConvertible, NSData) {
        
        // create url request to send
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        let boundaryConstant = "myRandomBoundary12345";
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // create upload data to send
        let uploadData = NSMutableData()
        
        if let imageData = imageData {
            // add image
            uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Disposition: form-data; name=\"\(imageData.key)\"; filename=\"file.jpg\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData(imageData.data)
        }
        // add parameters
        for (key, value) in parameters {
            uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        
        
        // return URLRequestConvertible and NSData
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }
    
    deinit {
        if let _ = startTime {
            let logStr = String(stringInterpolation:String(self.self), " is released, time spend on this request:\(spendTime) seconds"
            )
//            Log.infoLog(logStr, params: [], withFuncName: false)
        } else {
            let logStr = String(stringInterpolation:String(self.self), " is released without sending request"
            )
//            Log.infoLog(logStr, params: [], withFuncName: false)
        }
    }
}

extension Dictionary {
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}
