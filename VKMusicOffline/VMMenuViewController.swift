//
//  MasterViewController.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 20.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import UIKit
import VK

class VMMenuViewController: UITableViewController {
    
    // MARK: - IBOutlets
    
    // MARK: - VKUser
    var user : VKUser! {
        willSet (newUser) {
            if (newUser != nil) {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        initialize()
    }
    
    deinit {
        VMAudioListManager.sharedInstance.removeObserver(self, forKeyPath: "audioLists")
    }
    
    func initialize() {
        VMAudioListManager.sharedInstance.addObserver(self, forKeyPath: "audioLists", options: [.New, .Initial], context: nil)
    }
    
    // MARK: - UIViewController
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem()

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (VKSdk.isLoggedIn() && self.user == nil) {
            if (VMUserManager.sharedInstance.currentUser != nil) {
                self.user = VMUserManager.sharedInstance.currentUser
            } else {
                VMUserManager.sharedInstance.loadCurrentUser(completionBlock: { (user:VKUser) -> Void in
                    self.user = user
                }, errorBlock: { (error:NSError!) -> Void in
                    
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as!VMAudioListViewController
            let cell = sender as! VMMenuAudioListCell
            controller.audioList = cell.audioList
        }
    }

    // MARK: - Table View data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1 // User Info
        } else if section == 1 {
            return VMAudioListManager.sharedInstance.audioLists.count
        } else if section == 2 {
            return 3
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("VMMenuUserInfoCell", forIndexPath: indexPath) as! VMMenuUserInfoCell
            cell.user = self.user
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("VMMenuAudioListCell", forIndexPath: indexPath) as! VMMenuAudioListCell
            cell.audioList = VMAudioListManager.sharedInstance.audioLists[indexPath.row]
            return cell // VMMenuAudioListCell
        } else { // if indexPath.section == 2 {
            var cellID: String! = nil
            switch (indexPath.row) {
            case 0:
                cellID = "AddNewListCell"
            case 1:
                cellID = "DownloadsCell"
            case 2:
                cellID = "FriendsCell"
            default:
                cellID = ""
            }
            let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) 
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 124.0
        } else { // if indexPath.section == 1
            return 44.0
        }
    }
    
    // MARK: - Table View Delegate
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        if (indexPath.section == 1) {
            if let _ = VMAudioListManager.sharedInstance.audioLists[indexPath.row] as? VMOfflineAudioList {
                return true
            }
        }
        return false
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            if let list = VMAudioListManager.sharedInstance.audioLists[indexPath.row] as? VMOfflineAudioList {
                if (VMAudioListPlayer.sharedInstance.audioList === list) {
                    VMAudioListPlayer.sharedInstance.pause()
                    VMAudioListPlayer.sharedInstance.audioList = nil
                }
                VMAudioListManager.sharedInstance.removeOfflineAudioList(list)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // MARK: - KVO
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?,
        change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
            if (object as! NSObject == VMAudioListManager.sharedInstance) {
                if (keyPath == "audioLists") {
                    if self.tableView.editing == false {
                        self.tableView.reloadData()
                    }
                }
            }
    }
    
}

