//
//  VKSearchAudioList.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 21.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import UIKit
import VK

class VKSearchAudioList: VKOnlineAudioList {
    
    var searchTerm: NSString!
    
    override var request: VKRequest! {
    get {
        let parameters = [
            VK_API_Q: self.searchTerm,
            VK_API_SORT: 2,
            VK_API_OFFSET: self.currentPage,
            VK_API_COUNT: self.pageSize,
            "search_own": 1,
            "auto_complete": 1,
        ];
        return VKApi.requestWithMethod("audio.search",
            andParameters:parameters,
            andHttpMethod:"GET")
    }
    }
    
    init(with searchTerm: NSString!) {
        self.searchTerm = searchTerm
    }
}
