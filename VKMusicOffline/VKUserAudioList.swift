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
    override var request: VKRequest! {
        get {
            let parameters = [
                VK_API_OWNER_ID: self.user.id,
                VK_API_OFFSET: self.currentPage,
                VK_API_COUNT: self.pageSize,
            ];
            return VKApi.requestWithMethod("audio.get",
                andParameters:parameters,
                andHttpMethod:"GET")
        }
    }
    
    init(with user: VKUser) {
        self.user = user
    }
}
