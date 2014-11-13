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
            return VKApi.users().get(parameters)
        }
    }
    
    func loadCurrentUser(#completionBlock:((VKUser) -> Void), errorBlock:((NSError!) -> Void)) -> Void {
        NSLog("VMUserManager.loadCurrentUser starts...")
        self.userRequest.executeWithResultBlock({(response: VKResponse!) -> Void in
            println(response.json)
            println(response.parsedModel)
            if (response.parsedModel is VKUsersArray) {
                let userList : VKUsersArray = response.parsedModel as VKUsersArray
                if (userList.count > 0) {
                    NSLog("VMUserManager.loadCurrentUser got user : \(response.json)")
                    let user = userList[0] as VKUser
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
        
//        var a:VKUser? = nil;
//        a ?? self.currentUser
//        a = self.currentUser != nil ? self.currentUser : nil
    }
}
