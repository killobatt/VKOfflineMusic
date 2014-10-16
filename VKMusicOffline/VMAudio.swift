//
//  VMAudio.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 20.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import VK

class VMAudio: NSObject, NSCoding, Equatable {
    var id : NSNumber!
    var ownerID : NSNumber!
    var artist : NSString!
    var title : NSString!
    var URL : NSURL!
    var localFileName : NSString!
    var lyrics: VMLyrics!
    var albumID : NSNumber!
    var genreID : NSNumber!
    var duration : Int
    var durationString : NSString {
        get {
            let seconds = self.duration % 60
            let minutes = (self.duration % 3600) / 60
            if (self.duration > 3600) {
                let hours = self.duration / 3600
                return NSString(format: "%d:%02d:%02d", hours, minutes, seconds)
            } else {
                return NSString(format: "%d:%02d", minutes, seconds)
            }
        }
    }
    
    init(with audio: VKAudio) {
        self.id = audio.id
        self.ownerID = audio.owner_id
        self.artist = audio.artist
        self.title = audio.title
        if (audio.url != nil) {
            self.URL = NSURL.URLWithString(audio.url)
        }
        if (audio.lyrics_id != nil) {
            self.lyrics = VMLyrics(id: audio.lyrics_id)
        }
        self.albumID = audio.album_id
        self.genreID = audio.genre_id
        if (audio.duration != nil) {
            self.duration = audio.duration.integerValue
        } else {
            self.duration = 0
        }        
    }
    
    // MARK: - NSCoding interface implementation
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(self.id.integerValue, forKey: "id")
        aCoder.encodeInteger(self.ownerID.integerValue, forKey: "ownerID")
        aCoder.encodeInteger(self.duration, forKey: "duration")
        aCoder.encodeOptional(self.artist, forKey: "artist")
        aCoder.encodeOptional(self.title, forKey: "title")
        aCoder.encodeOptional(self.URL, forKey: "URL")
        aCoder.encodeOptional(self.localFileName, forKey: "localFileName")
        aCoder.encodeOptional(self.lyrics, forKey: "lyrics")
        aCoder.encodeOptional(self.albumID, forKey: "albumID")
        aCoder.encodeOptional(self.genreID, forKey: "genreID")
    }
    
    required init(coder aDecoder: NSCoder) {
        self.id = NSNumber(int: aDecoder.decodeIntForKey("id"))
        self.ownerID = NSNumber(int: aDecoder.decodeIntForKey("ownerID"))
        self.duration = NSNumber(int: aDecoder.decodeIntForKey("duration"))
        self.artist = aDecoder.decodeObjectForKey("artist") as NSString!
        self.title = aDecoder.decodeObjectForKey("title") as NSString!
        self.URL = aDecoder.decodeObjectForKey("URL") as NSURL!
        self.localFileName = aDecoder.decodeObjectForKey("localFileName") as NSString!
        self.albumID = aDecoder.decodeObjectForKey("albumID") as NSNumber!
        super.init()
        self.lyrics = aDecoder.decodeObjectForKey("lyricsID") as VMLyrics!
        if (self.lyrics != nil) {
            self.lyrics.audio = self
        }
    }
    
    // MARK: - Equatable
    
}

func ==(lhs: VMAudio, rhs: VMAudio) -> Bool {
    return lhs.id == rhs.id
}
