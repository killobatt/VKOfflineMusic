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
    
    override init() {
        super.init()
        initialize()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initialize()
    }
    
    deinit {
        VMAudioListManager.sharedInstance.removeObserver(self, forKeyPath: "audioLists")
    }
    
    func initialize() {
        VMAudioListManager.sharedInstance.addObserver(self, forKeyPath: "audioLists", options: nil, context: nil)
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
            let controller = (segue.destinationViewController as UINavigationController).topViewController as VMAudioListViewController
            let cell = sender as VMMenuAudioListCell
            controller.audioList = cell.audioList
        }
    }

    // MARK: - Table View data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1 // User Info
        } else if section == 1 {
            return VMAudioListManager.sharedInstance.audioLists.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("VMMenuUserInfoCell", forIndexPath: indexPath) as VMMenuUserInfoCell
            cell.user = self.user
            return cell
        } else { // if indexPath.section == 1
            let cell = tableView.dequeueReusableCellWithIdentifier("VMMenuAudioListCell", forIndexPath: indexPath) as VMMenuAudioListCell
            cell.audioList = VMAudioListManager.sharedInstance.audioLists[indexPath.row]
            return cell // VMMenuAudioListCell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 124.0
        } else { // if indexPath.section == 1
            return 44.0
        }
    }
    
    
    // MARK: - KVO
    
    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!,
        change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<Void>) {
            if (object as NSObject == VMAudioListManager.sharedInstance) {
                if (keyPath == "audioLists") {
                    self.tableView.reloadData()
                }
            }
    }
    
}

