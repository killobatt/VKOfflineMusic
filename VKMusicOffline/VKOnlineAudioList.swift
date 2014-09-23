//
//  VKOnlineAudioList.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 20.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import UIKit
import VK

class VKOnlineAudioList: VKAudioList {

    var pageSize: Int = 20
    var currentPage: Int = 0
    
    var request: VKRequest! {
        get {
            return nil
        }
    }

    func loadNextPage(#completion:((NSError!) -> Void)?) -> Void {
        self.currentPage++
        if (self.request) {
            self.request.executeWithResultBlock({(response: VKResponse!) -> Void in
                let audios = VKAudios(dictionary:response.json as NSDictionary)
                for (var i: UInt = 0; i < audios.count; i++) {
                    let audio = audios[i] as VKAudio
                    self.audios.append(VKOfflineAudio(with: audio))
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
