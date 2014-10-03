//
//  VMAudioListPlayer.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodko on 30.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import AVFoundation

class VMAudioListPlayer: NSObject {
    
    class var sharedInstance : VMAudioListPlayer {
    struct Static {
        static var onceToken : dispatch_once_t = 0
        static var instance : VMAudioListPlayer? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = VMAudioListPlayer()
        }
        return Static.instance!
    }
    
    var player: AVPlayer!
    var audioList: VMAudioList!
    
    var currentTrack: VMAudio! {
        get {
            return self.audioList[self.currentTrackIndex]
        }
        set {
            let index = find(self.audioList.audios, newValue)
            assert(index != nil, "Set currentTrack failed: \(newValue) is not found in list \(self.audioList)")
            self.currentTrackIndex = index!
        }
    }
    
    var currentTrackIndex: Int = 0 {
        didSet {
            self.currentTrack = self.audioList[self.currentTrackIndex]
        }
    }
    
    override init() {
        
    }
}
