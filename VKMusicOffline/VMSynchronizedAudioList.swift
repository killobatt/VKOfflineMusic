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
    
    /// MARK: - 
    
    func synchronize(completion: (error: NSError) -> Void) {
        
    }
    
    
    /// MARK: - Private
    private var onlineAudioList: VMOnlineAudioList
}
