//
//  ViewController.swift
//  DevCon iOS App
//
//  Created by Mary Alexis Solis on 14/05/2016.
//  Copyright © 2016 Mary Alexis Solis. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AlamofireImage

struct Item {
    var userName: String?
    var fullName: String?
    var avatarUrl: String?
    var avatar: UIImage?
}

class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIView!
    
    var items: [Item] = []
    
    let rowHeight: CGFloat = 120.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.callAPI()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func hideLoadingIndicator() {
        self.loadingIndicator.hidden = true
    }
    
    func showLoadingIndicator() {
        self.loadingIndicator.hidden = false
    }
    
    
    func callAPI() {
        self.showLoadingIndicator()
        
        Alamofire.request(.GET, "https://api.prime58.com/v1/posts/?access_token=test")
            .responseJSON { response in
                
            self.hideLoadingIndicator()
                
            let json = JSON(response.result.value!)
            print(json)
            
            for (_,subJson):(String, JSON) in json {
                self.items.append (
                    Item(userName: subJson["username"].string,
                        fullName: subJson["full_name"].string,
                        avatarUrl: subJson["thumbnail"].string, avatar: nil)
                )
            }
    
            self.tableView.reloadData()
        }
        
    }

}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell =
            self.tableView?.dequeueReusableCellWithIdentifier("Cell")
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        }
        
        cell!.textLabel?.text = self.items[indexPath.row].userName
        cell!.imageView?.image = self.items[indexPath.row].avatar
        
        if self.items[indexPath.row].avatar == nil {
            cell!.imageView?.image = UIImage(named: "ImagePlaceholder")
            
            Alamofire.request(.GET, self.items[indexPath.row].avatarUrl!)
                .responseImage { response in

                if let avatar = response.result.value {
                    self.items[indexPath.row].avatar = avatar
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                }
            }
        }
        
        return cell!
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
        
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return rowHeight
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.selected = false
    }

}
