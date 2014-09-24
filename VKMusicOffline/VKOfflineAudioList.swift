//
//  VKOfflineAudioList.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 24.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import UIKit

class VKOfflineAudioList: VKAudioList, NSCoding {
    
    var name: NSString!
    var identifier: NSUUID
    
    // MARK: - NSCoding interface implementation
    
    func encodeWithCoder(aCoder: NSCoder!) {
        aCoder.encodeObject(self.identifier, forKey: "identifier")
    }
    
    init(coder aDecoder: NSCoder!) {
        self.identifier = aDecoder.decodeObjectForKey("identifier") as NSUUID
        self.ownerID = NSNumber(int: aDecoder.decodeIntForKey("ownerID"))
        self.artist = aDecoder.decodeObjectForKey("artist") as NSString
        self.title = aDecoder.decodeObjectForKey("title") as NSString
        self.URL = aDecoder.decodeObjectForKey("URL") as NSURL
        self.localURL = aDecoder.decodeObjectForKey("localURL") as NSURL
        self.lyricsID = aDecoder.decodeObjectForKey("lyricsID") as NSNumber
        self.albumID = aDecoder.decodeObjectForKey("albumID") as NSNumber
        self.duration = NSNumber(int: aDecoder.decodeIntForKey("artist"))
    }
    
}
