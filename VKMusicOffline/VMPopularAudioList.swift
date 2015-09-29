//
//  VMPopularAudioList.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodko on 28.09.15.
//  Copyright © 2015 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import VK

class VMPopularAudioList: VMOnlineAudioList {
    
    var onlyEnglish: Bool = false
    var genreID: Int? = nil
    
    override var parameters: NSDictionary {
        get {
            let parameters: NSMutableDictionary = [
                "only_eng" : self.onlyEnglish ? 1 : 0,
            ];
            if let genreID = self.genreID {
                parameters["genre_id"] = genreID
            }
            parameters.addEntriesFromDictionary(super.parameters as [NSObject : AnyObject])
            return parameters
        }
    }
    
    override func createRequest() -> VKRequest {
        return VKApi.requestWithMethod("audio.getPopular",
            andParameters:self.parameters as [NSObject : AnyObject],
            andHttpMethod:"GET")
    }

    override var searchResultsList: VMAudioList? {
        get {
            return VMSearchAudioList(searchOwn: true)
        }
    }
    
}
