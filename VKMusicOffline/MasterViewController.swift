//
//  MasterViewController.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 20.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import UIKit
import VK

class MasterViewController: UITableViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    
    var user : VKUser! {
    willSet (newUser) {
        self.firstNameLabel.text = newUser.first_name
        self.lastNameLabel.text = newUser.last_name
        NSURLSession.sharedSession().dataTaskWithURL(NSURL.URLWithString(newUser.photo_100),
            completionHandler: {(data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
                let img: UIImage = UIImage(data: data)
                self.userImageView.image = img
            })
    }
    }

    var detailViewController: DetailViewController? = nil


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
        
        let userRequest = VKApi.users().get()
        userRequest.executeWithResultBlock({(response: VKResponse!) -> Void in
            println(response.json)
            println(response.parsedModel)
            if (response.parsedModel is VKUsersArray) {
                let userList : VKUsersArray = response.parsedModel as VKUsersArray
                if (userList.count > 0) {
                    let user: VKUser = userList[0] as VKUser
                    let parameters = [
                        VK_API_USER_ID : user.id,
                        VK_API_FIELDS : ["first_name", "last_name", "photo_100", "status"]
                    ]
                    let userDetailsRequest = VKApi.users().get(parameters)
                    userDetailsRequest.executeWithResultBlock({(response: VKResponse!) -> Void in
                        let userList : VKUsersArray = VKUsersArray(array:response.json as NSArray)
                        self.user = userList[0] as VKUser
                        }, errorBlock: {(error: NSError!) -> Void in
                            println(userDetailsRequest.getPreparedRequest())
                            println(userDetailsRequest.getPreparedRequest().URL)
                            println(userDetailsRequest.methodName)
                            println(userDetailsRequest.methodParameters)
                            println(error)
                        })
                }
            }
            }, errorBlock:{(error: NSError!) -> Void in
                println(error)
            })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let controller = (segue.destinationViewController as UINavigationController).topViewController as DetailViewController
//            controller.detailItem = 
            controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem()
        }
    }

    // MARK: - Table View


}

