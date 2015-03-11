//
//  VMSynchronizedAudioList.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 11.03.15.
//  Copyright (c) 2015 Vjacheslav Volodko. All rights reserved.
//

import UIKit


// offline audio list which can synchronize with online one.
class VMSynchronizedAudioList: VMOfflineAudioList {
    
    init(onlineAudioList: VMOnlineAudioList) {
        self.onlineAudioList = onlineAudioList
        super.init(title: onlineAudioList.title)
    }

    /// MARK: - NSCoding
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
    }
    
    /// MARK: - Sync
    
    func synchronize(completion: (error: NSError?) -> Void) {
        self.ensureListLoaded(nil, completion: { (error: NSError?) -> Void in
            
        })
    }
    
    private func ensureListLoaded(error:NSError?, completion completionClosure: (error: NSError?) -> Void) {
        assert(self.onlineAudioList != nil)
        if (error != nil) {
            completionClosure(error: error)
            return
        }
        
        if let onlineList = self.onlineAudioList {
            if (onlineList.hasNextPage()) {
                var loadNextPageCompletion: ((NSError!) -> Void)? =
                { (loadPageError: NSError!) -> Void in
                    self.ensureListLoaded(loadPageError, completion:completionClosure)
                }
                onlineList.loadNextPage(completion: loadNextPageCompletion)
            } else {
                completionClosure(error: nil)
            }
        }
    }
    
//    private func getMissingAudios() -> Array<VMAudio> {
//        assert(self.onlineAudioList != nil)
//        assert(self.onlineAudioList?.hasNextPage() == false)
//        
//        
//    }
    
    /// MARK: - Private
    private var onlineAudioList: VMOnlineAudioList?
}
