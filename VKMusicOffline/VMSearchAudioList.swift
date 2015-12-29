//
//  VMSearchAudioList.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 21.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import VKSdkFramework

class VMSearchAudioList: VMOnlineAudioList, VMAudioListSearching {
    
    override var method: String! {
        return "audio.search"
    }
    
    override var parameters: NSDictionary {
        get {
            let parameters: NSMutableDictionary = [
                VK_API_Q: self._searchTerm,
                VK_API_SORT: 2,
                "search_own": self.searchOwn ? 1 : 0,
                "auto_complete": 1,
            ];
            parameters.addEntriesFromDictionary(super.parameters as [NSObject : AnyObject])
            return parameters
        }
    }
    
    private var searchOwn: Bool = false
    
    init(searchOwn:Bool) {
        super.init()
        self.searchOwn = searchOwn;
    }
    
    // MARK: - VMAudioListSearching
    
    var searchTerm: String! { get { return self._searchTerm } }

    private var _searchTerm: String!

    func setSearchTerm(searchTerm: String!, completion:((NSError!) -> Void)?) -> Void {
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
