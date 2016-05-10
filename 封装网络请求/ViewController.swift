//
//  ViewController.swift
//  封装网络请求
//
//  Created by Xinxibin on 16/4/15.
//  Copyright © 2016年 Xinxibin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var dataArray : [BaseModel] = []
    private var request:HomeDataRequest!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()
        
    }
    func getData() {
        request = HomeDataRequest()
        request.callBack = self
        request.loadFirstPage()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - UITableViewDelegate , UItableViewDataSource

extension ViewController : UITableViewDataSource {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let model = dataArray[indexPath.row]
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        
        let url = NSURL(string: model.avatar!)
        let data = NSData(contentsOfURL: url!)
        cell.imageView?.image = UIImage(data: data!)
        cell.textLabel?.text = model.msg
        cell.detailTextLabel?.text = model.vtypemeans
        return cell
        
    }
}

extension ViewController : UITableViewDelegate {
    
    
}


/*!
 请求回调
 */
extension ViewController : FMBaseAPIManagerCallBack {
    
    func managerApiCallBackSuccess(manager: MyBaseAPIManager, result: [String : AnyObject]) {
        
        
        let params = HomeDataRequest.handResult(result)
        dataArray = params
        self.tableView.reloadData()
        
    }
    

    func managerApiCallBackFailed(manager: MyBaseAPIManager, errorInfo: String) {
        
        print(errorInfo)
    }
    
    
}