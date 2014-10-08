//
//  VMUserAudioList.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 21.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import VK

class VMUserAudioList: VMOnlineAudioList {
    
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
    
    override func createRequest() -> VKRequest {
        return VKApi.requestWithMethod("audio.get",
            andParameters:self.parameters,
            andHttpMethod:"GET")
    }
    
    init(with user: VKUser) {
        self.user = user
        super.init()
    }
}
