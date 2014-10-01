//
//  VMOnlineAudioList.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 20.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import VK

func MIN<T: Comparable>(a: T, b: T) -> T {
    if (a < b) {
        return a
    } else {
        return b
    }
}

class VMOnlineAudioList: VMAudioList {

    var pageSize: Int = 20
    var currentPageOffset: Int = 0
    private var totalCount: Int = 0
    
    var parameters: NSDictionary {
        get {
            return [
                VK_API_OFFSET: self.currentPageOffset,
                VK_API_COUNT: self.pageSize,
            ]
        }
    }

    var request: VKRequest! {
        get {
            return nil
        }
    }
    
    override func hasNextPage() -> Bool {
        return self.audios.count < self.totalCount
    }
    
    override func loadNextPage(#completion:((NSError!) -> Void)?) -> Void {
        assert(self.request != nil, "Child class should provide a valid request")
        
        if (self.request.isExecuting) {
            return
        }
        
        NSLog("VMUserManager.loadCurrentUser starts...")
        self.request.executeWithResultBlock({(response: VKResponse!) -> Void in
            
            let audios = VKAudios(dictionary:response.json as NSDictionary)
            self.totalCount = Int(audios.count)
            for (var i = 0; i < MIN(self.pageSize, Int(audios.items.count)); i++) {
                let audio = audios[UInt(i)] as VKAudio
                self.audios.append(VMAudio(with: audio))
            }
            self.currentPageOffset += self.pageSize
            
            NSLog("VMUserManager.loadCurrentUser got audios: \(response.json)")
            if let _completion = completion {
                _completion(nil)
            }
        }, errorBlock: {(error: NSError!) -> Void in
            NSLog("VMUserManager.loadCurrentUser got error: \(error)")
            if let _completion = completion {
                _completion(error)
            }
        })
    }
}
