//
//  VKOfflineAudio.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 20.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import UIKit
import VK

class VKOfflineAudio: NSObject {
    var id : NSNumber!
    var ownerID : NSNumber!
    var artist : NSString!
    var title : NSString!
    var URL : NSURL!
    var localURL : NSURL!
    var lyricsID : NSNumber!
    var albumID : NSNumber!
    var genreID : NSNumber!
    var duration : Int
    var durationString : NSString {
        get {
            let seconds = self.duration % 60
            let minutes = (self.duration % 3600) / 60
            if (self.duration > 3600) {
                let hours = self.duration / 3600
                return "\(hours):\(minutes):\(seconds)"
            } else {
                return "\(minutes):\(seconds)"
            }
        }
    }
    
    init(with audio: VKAudio) {
        self.id = audio.id
        self.ownerID = audio.owner_id
        self.artist = audio.artist
        self.title = audio.title
        if (audio.url) {
            self.URL = NSURL.URLWithString(audio.url)
        }
        self.lyricsID = audio.lyrics_id
        self.albumID = audio.album_id
        self.genreID = audio.genre_id
        if (audio.duration) {
            self.duration = audio.duration.integerValue
        } else {
            self.duration = 0
        }        
    }
 
}
