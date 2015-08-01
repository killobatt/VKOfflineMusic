//
//  VMUserManager.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodko on 30.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import VK

class VMUserManager: NSObject {

    var currentUser: VKUser!
    
    
    class var sharedInstance : VMUserManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : VMUserManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = VMUserManager()
        }
        return Static.instance!
    }

    private var userRequest: VKRequest {
        get {
            let parameters = [
                VK_API_USER_ID: VKSdk.getAccessToken().userId,
                VK_API_FIELDS : ["first_name", "last_name", "photo_200", "status"]
            ]
            return VKApi.users().get(parameters as [NSObject : AnyObject])
        }
    }
    
    func loadCurrentUser(#completionBlock:((VKUser) -> Void), errorBlock:((NSError!) -> Void)) -> Void {
        NSLog("VMUserManager.loadCurrentUser starts...")
        self.userRequest.executeWithResultBlock({(response: VKResponse!) -> Void in
            println(response.json)
            println(response.parsedModel)
            if (response.parsedModel is VKUsersArray) {
                let userList : VKUsersArray = response.parsedModel as! VKUsersArray
                if (userList.count > 0) {
                    NSLog("VMUserManager.loadCurrentUser got user : \(response.json)")
                    let user = userList[0] as! VKUser
                    self.currentUser = user
                    completionBlock(user)
                    return
                }
            }
            // TODO: insert error here
            NSLog("VMUserManager.loadCurrentUser got invalid json : \(response.json)")
            errorBlock(nil)
            }, errorBlock:{(error: NSError!) -> Void in
                NSLog("VMUserManager.loadCurrentUser got error: \(error)")
                errorBlock(error)
        })
    }
    
    var friends: VKUsersArray?
    
    private var friendsRequest: VKRequest {
        let parameters = [
            VK_API_USER_ID: VKSdk.getAccessToken().userId,
            VK_API_FIELDS : ["first_name", "last_name", "photo_100", "online"],
            "order" : "hints"
        ]
        return VKApi.friends().get(parameters as [NSObject : AnyObject])
    }
    
    func loadFriends(#completion:((VKUsersArray) -> Void), errorBlock:((NSError!) -> Void)) {
        self.friendsRequest.executeWithResultBlock({ (response: VKResponse!) -> Void in
            NSLog("VMUserManager.loadFriends got response: \(response)")
            if let friends = response.parsedModel as? VKUsersArray {
                completion(friends)
                self.friends = friends
            }
            }, errorBlock: { (error: NSError!) -> Void in
            NSLog("VMUserManager.loadFriends got error: \(error)")
                errorBlock(error)
        })
    }
}
