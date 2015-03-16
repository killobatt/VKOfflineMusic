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
    
    init(identifier:String) {
        super.init(title: "")
        self.identifier = identifier
    }

    /// MARK: - NSCoding
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
    }
    
    /// MARK: - Sync
    
    func synchronize() {
        self.ensureListLoaded(nil, completion: { (error: NSError?) -> Void in
            
            if error != nil {
                return
            }
            
            // Merge is simple: 
            // 1. Take all audios from online list
            // 2. Download missing audio files 
            
            var oldAudios = self.audios
            if let newAudios = self.onlineAudioList?.audios {
                self.audios = newAudios
                for newAudio in newAudios {
                    if let mappedOldAudioIndex = find(oldAudios.map{ $0.id }, newAudio.id) {
                        newAudio.localFileName = oldAudios[mappedOldAudioIndex].localFileName
                    } else {
                        // TODO: We should not know anything aboud VMAudioListManager
                        VMAudioListManager.sharedInstance.downloadAudio(newAudio)
                    }
                }
            }
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
    
    /// MARK: -
    internal var onlineAudioList: VMOnlineAudioList?
    
    override var title: NSString! {
        get {
            return self.onlineAudioList?.title
        }
        set {
            self.onlineAudioList?.title = newValue
        }
    }

}
