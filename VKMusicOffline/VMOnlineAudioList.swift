//
//  VMOnlineAudioList.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 20.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import VKSdkFramework

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
    
    var method: String! {
        return nil
    }
    
    var parameters: NSDictionary {
        get {
            return [
                VK_API_OFFSET: self.currentPageOffset,
                VK_API_COUNT: self.pageSize,
            ]
        }
    }

    func createRequest() -> VKRequest {
        return VKApi.requestWithMethod(self.method, andParameters:self.parameters as [NSObject : AnyObject])
    }
    
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
        
        VMLog("VMOnlineAudioList.loadNextPage starts (loading \(self.pageSize) audios with offset \(self.currentPageOffset) ...")
        self.request.executeWithResultBlock({(response: VKResponse!) -> Void in
            
            var audios : VKAudios! = nil
            if let audioJSONDictionary = response?.json as? [NSObject : AnyObject] {
                audios = VKAudios(dictionary: audioJSONDictionary)
            } else if let audioJSONArray = response?.json as? [AnyObject] {
                audios = VKAudios(array: audioJSONArray)
            }
            
            self.totalCount = Int(audios.count)
            var audioArray : [VMAudio] = self.audios
            for (var i = 0; i < MIN(self.pageSize, b: Int(audios.items.count)); i++) {
                let audio = audios[UInt(i)] as! VKAudio
                audioArray.append(VMAudio(audio: audio))
            }
            
            self.audios = audioArray
            
            self.currentPageOffset += self.pageSize
            
            VMLog("VMOnlineAudioList.loadNextPage got audios: \(response.json)")
            if let _completion = completion {
                _completion(nil)
            }
        }, errorBlock: {(error: NSError!) -> Void in
            VMLog("VMOnlineAudioList.loadNextPage got error: \(error)")
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
                VMLog("Cancelling request: \(self.request)")
                self.request.cancel()
            }
            self.request = nil
        }
    }
    
    override func reload() {
        self.delegate?.audioListWillChange(self)
        
        let change = VMAudioListChangeInfo()
        change.removedAudios = VMAudioListChangeInfo.removedAudiosForAudios(self.audios, fromAudioList: self)
        
        self.resetList()
        self.delegate?.audioList(self, didChangeWithInfo: change)
        
        self.loadNextPage { (error: NSError!) -> Void in
            self.delegate?.audioListWasReloaded(self)
        }
    }
}
