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
    
    var parameters: NSDictionary {
        get {
            return [
                VK_API_OFFSET: self.currentPageOffset,
                VK_API_COUNT: self.pageSize,
            ]
        }
    }

    func createRequest() -> VKRequest! { return nil }
    
    private var request: VKRequest! = nil
    
    override func hasNextPage() -> Bool {
        return self.audios.count < self.totalCount
    }
    
    override func loadNextPage(completion completion:((NSError!) -> Void)?) -> Void {
        
        if (self.currentPageOffset > self.totalCount) {
            return
        }
        
        if (self.request != nil && self.request.isExecuting) {
            return
        } else {
            self.request = self.createRequest()
        }
        
        NSLog("VMOnlineAudioList.loadNextPage starts (loading \(self.pageSize) audios with offset \(self.currentPageOffset) ...")
        self.request.executeWithResultBlock({(response: VKResponse!) -> Void in
            
            let audios = VKAudios(dictionary:(response.json as! [NSObject : AnyObject]))
            self.totalCount = Int(audios.count)
            let audioArray = NSMutableArray(capacity: audios.items.count)
            for (var i = 0; i < MIN(self.pageSize, b: Int(audios.items.count)); i++) {
                let audio = audios[UInt(i)] as! VKAudio
                audioArray.addObject(VMAudio(with: audio))
            }
            self.audios = self.audios.arrayByAddingObjectsFromArray(audioArray as [AnyObject])
            self.currentPageOffset += self.pageSize
            
            NSLog("VMOnlineAudioList.loadNextPage got audios: \(response.json)")
            if let _completion = completion {
                _completion(nil)
            }
        }, errorBlock: {(error: NSError!) -> Void in
            NSLog("VMOnlineAudioList.loadNextPage got error: \(error)")
            if let _completion = completion {
                _completion(error)
            }
        })
    }
    
    func resetList() {
        self.audios = []
        self.currentPageOffset = 0
        self.totalCount = 0
        
        if let request = self.request {
            if request.isExecuting {
                NSLog("Cancelling request: \(self.request)")
                self.request.cancel()
            }
            self.request = nil
        }
    }
}
