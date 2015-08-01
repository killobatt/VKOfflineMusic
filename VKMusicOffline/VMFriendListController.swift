//
//  VMFriendListController.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodko on 31.07.15.
//  Copyright (c) 2015 Vjacheslav Volodko. All rights reserved.
//

import UIKit
import VK

class VMFriendListController: UITableViewController {
    
    // MARK: - Model
    
    var friends: VKUsersArray? {
        return VMUserManager.sharedInstance.friends
    }
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 70

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        VMUserManager.sharedInstance.loadFriends(completion: { (friends: VKUsersArray) -> Void in
            self.tableView.reloadData()
            }) { (error: NSError!) -> Void in
            
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(self.friends?.count ?? 0)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as! VMFriendCell
        
        if let friend = self.friends?.objectAtIndex(indexPath.row) as? VKUser {
            cell.user = friend
        }
        
        return cell
    }
}
