//
//  VMOnlineAudioList.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 20.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import VK

class VMOnlineAudioList: VMAudioList {

    var pageSize: UInt = 20
    var currentPage: UInt = 0
    private var totalCount: UInt = 0
    
    override var count: Int {
        get {
            return Int(self.totalCount)
        }
    }
    
    var parameters: NSDictionary {
        get {
            return [
                VK_API_OFFSET: self.currentPage,
                VK_API_COUNT: self.pageSize,
            ]
        }
    }

    var request: VKRequest! {
        get {
            return nil
        }
    }
    
    func loadNextPage(#completion:((NSError!) -> Void)?) -> Void {
        self.currentPage++
        if (self.request != nil) {
            self.request.executeWithResultBlock({(response: VKResponse!) -> Void in
                let audios = VKAudios(dictionary:response.json as NSDictionary)
                self.totalCount = audios.count
                for (var i: UInt = 0; i < self.pageSize; i++) {
                    let audio = audios[i] as VKAudio
                    self.audios.append(VMAudio(with: audio))
                }
                if let _completion = completion {
                    _completion(nil)
                }
            }, errorBlock: {(error: NSError!) -> Void in
                if let _completion = completion {
                    _completion(error)
                }
            })
        } else {
            assert(false, "Child class should provide a valid request")
        }
    }
}
