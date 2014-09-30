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
                self.userAudioList = VMUserAudioList(with: newUser)
                self.userAudioList.title = "Мои аудиозаписи"
                self.userAudioList.loadNextPage(completion: nil)
                self.searchAudioList = VMSearchAudioList(with: "")
                self.searchAudioList.title = "Поиск"
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - VMAudioLists
    var userAudioList: VMUserAudioList!
    var searchAudioList: VMSearchAudioList!
    var resentAudioList: VMAudioList!
    var allOfflineAudioList: VMAudioList!
    var audioLists: Array<VMAudioList> {
        get {
            var lists: Array<VMAudioList> = []
            if self.userAudioList != nil {
                lists.append(self.userAudioList)
            }
            if self.searchAudioList != nil {
                lists.append(self.searchAudioList)
            }
            if self.resentAudioList != nil {
                lists.append(self.resentAudioList)
            }
            if self.allOfflineAudioList != nil {
                lists.append(self.allOfflineAudioList)
            }
            return lists
        }
    }
    
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
            let parameters = [
                VK_API_USER_ID: VKSdk.getAccessToken().userId,
                VK_API_FIELDS : ["first_name", "last_name", "photo_100", "status"]
            ]
            let userRequest = VKApi.users().get(parameters)
            userRequest.executeWithResultBlock({(response: VKResponse!) -> Void in
                println(response.json)
                println(response.parsedModel)
                if (response.parsedModel is VKUsersArray) {
                    let userList : VKUsersArray = response.parsedModel as VKUsersArray
                    if (userList.count > 0) {
                        self.user = userList[0] as VKUser
                    }
                }
                }, errorBlock:{(error: NSError!) -> Void in
                    println(error)
            })
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
            return self.audioLists.count
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
            cell.audioList = self.audioLists[indexPath.row]
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
    
}

