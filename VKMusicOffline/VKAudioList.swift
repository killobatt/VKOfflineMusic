//
//  VKAudioList.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 20.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import UIKit
import VK

class VKAudioList: NSObject {
    
    var audios : Array< VKOfflineAudio > = []
    
    var title : NSString!
    
    subscript(index: Int) -> VKOfflineAudio {
        get {
            return audios[index]
        }
        set (newValue) {
            audios[index] = newValue
        }
    }
    
    var count: Int {
        get {
            return self.audios.count
        }
    }
}
