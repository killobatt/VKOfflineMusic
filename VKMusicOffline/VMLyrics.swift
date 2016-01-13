//
//  VMLyrics.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 01.10.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import UIKit
import VKSdkFramework
import CoreDataStorage

class VMLyrics: NSObject, NSCoding {
    var id: NSNumber
    var text: String!
    var audio: VMAudio!
    
    init(audio:VMAudio, identifier id:NSNumber) {
        self.audio = audio
        self.id = id
    }
    
    func loadText(completion completion:((NSError!) -> Void)?) -> Void {
        VMLog("VMLyrics.loadText starting...")
        let lyricsRequest = VKApi.requestWithMethod("audio.getLyrics", andParameters: ["lyrics_id" : self.id])
        
        lyricsRequest.executeWithResultBlock({ (response: VKResponse!) -> Void in
            if let vkObject = response.json as? NSDictionary,
                let text = vkObject["text"] as? String {
                self.text = text
                VMLog("VMLyrics.loadText got text: \(text.stringByPaddingToLength(50, withString: "...", startingAtIndex: 0))")
            }
            completion?(nil)
        }, errorBlock: { (error:NSError!) -> Void in
            completion?(error)
        })
    }
    
    init(audio:VMAudio, storedLyrics: CDLyrics) {
        self.audio = audio
        self.id = storedLyrics.id!
        self.text = storedLyrics.text
    }
    
    // MARK: - NSCoding
    
    required init(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObjectForKey("id") as! NSNumber
        self.text = aDecoder.decodeObjectForKey("text") as! String!
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.id, forKey: "id")
        aCoder.encodeOptional(self.text, forKey: "text")
    }
    
}
