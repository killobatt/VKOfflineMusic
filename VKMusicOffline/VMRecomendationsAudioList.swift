//
//  VMRecomendationsAudioList.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodko on 20.06.15.
//  Copyright (c) 2015 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import VKSdkFramework

class VMRecomendationsAudioList: VMOnlineAudioList {
   
    var user: VKUser
    var shuffle: Bool = true;
    
    override var method: String! {
        return "audio.getRecommendations"
    }
    
    override var parameters: NSDictionary {
        get {
            let parameters: NSMutableDictionary = [
                VK_API_USER_ID: self.user.id,
                "shuffle" : self.shuffle ? 1 : 0,
            ];
            parameters.addEntriesFromDictionary(super.parameters as [NSObject : AnyObject])
            return parameters
        }
    }
    
    init(user: VKUser) {
        self.user = user
        super.init()
    }
    
    override var searchResultsList: VMAudioList? {
        get {
            return VMSearchAudioList(searchOwn: true)
        }
    }

}
