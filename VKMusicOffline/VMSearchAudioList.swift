//
//  VMSearchAudioList.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 21.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import VK

class VMSearchAudioList: VMOnlineAudioList {
    
    override var parameters: NSDictionary {
        get {
            let parameters: NSMutableDictionary = [
                VK_API_Q: self.searchTerm,
                VK_API_SORT: 2,
                "search_own": 1,
                "auto_complete": 1,
            ];
            parameters.addEntriesFromDictionary(super.parameters)
            return parameters
        }
    }
    
    override func createRequest() -> VKRequest! {
        return VKApi.requestWithMethod("audio.search",
            andParameters:self.parameters,
            andHttpMethod:"GET")
    }
    
}
