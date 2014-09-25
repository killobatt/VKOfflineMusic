//
//  VKUserAudioList.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 21.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import UIKit
import VK

class VKUserAudioList: VKOnlineAudioList {
    
    var user: VKUser
    
    override var parameters: NSDictionary {
        get {
            let parameters: NSMutableDictionary = [
                VK_API_OWNER_ID: self.user.id,
            ];
            parameters.addEntriesFromDictionary(super.parameters)
            return parameters
        }
    }
    
    override var request: VKRequest! {
        get {
            return VKApi.requestWithMethod("audio.get",
                andParameters:self.parameters,
                andHttpMethod:"GET")
        }
    }
    
    init(with user: VKUser) {
        self.user = user
    }
}
