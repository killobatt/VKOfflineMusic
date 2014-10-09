//
//  VMSearchAudioList.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 21.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import VK

class VMSearchAudioList: VMOnlineAudioList, VMAudioListSearching {
    
    override var parameters: NSDictionary {
        get {
            let parameters: NSMutableDictionary = [
                VK_API_Q: self._searchTerm,
                VK_API_SORT: 2,
                "search_own": self.searchOwn ? 1 : 0,
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
    
    private var searchOwn: Bool = false
    
    init(searchOwn:Bool) {
        super.init()
        self.searchOwn = searchOwn;
    }
    
    // MARK: - VMAudioListSearching
    
    var searchTerm: NSString! { get { return self._searchTerm } }

    private var _searchTerm: NSString!

    func setSearchTerm(searchTerm: NSString!, completion:((NSError!) -> Void)?) -> Void {
        self._searchTerm = searchTerm;
        self.resetList()
        self.loadNextPage(completion: completion)
    }
    
    override var searchResultsList: VMAudioList? {
        get {
            return self
        }
    }
}
