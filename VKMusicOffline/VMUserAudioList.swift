//
//  VMUserAudioList.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 21.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import VKSdkFramework

class VMUserAudioList: VMOnlineAudioList {
    
    var user: VKUser
    
    override var method: String! {
        return "audio.get"
    }
    
    override var parameters: NSDictionary {
        get {
            let parameters: NSMutableDictionary = [
                VK_API_OWNER_ID: self.user.id,
            ];
            parameters.addEntriesFromDictionary(super.parameters as [NSObject : AnyObject])
            return parameters
        }
    }
    
    init(with user: VKUser) {
        self.user = user
        super.init()
    }
    
    override var searchResultsList: VMAudioList? {
        get {
            return VMSearchAudioList(searchOwn: true)
        }
    }
}
