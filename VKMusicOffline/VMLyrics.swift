//
//  VMLyrics.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 01.10.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import UIKit
import VK
import CoreDataStorage

class VMLyrics: NSObject, NSCoding {
    var id: NSNumber
    var text: String!
    var audio: VMAudio!
    
    init(audio:VMAudio, identifier id:NSNumber) {
        self.audio = audio
        self.id = id
    }
    
    func loadText(#completion:((NSError!) -> Void)?) -> Void {
        NSLog("VMLyrics.loadText starting...")
        var lyricsRequest = VKApi.requestWithMethod("audio.getLyrics",
            andParameters: ["lyrics_id" : self.id],
            andHttpMethod: "GET")
        
        lyricsRequest.executeWithResultBlock({ (response: VKResponse!) -> Void in
            NSLog("VMLyrics.loadText got text: \(response.json)")
            if response.json is NSDictionary {
                let vkObject = response.json as! NSDictionary
                self.text = vkObject["text"] as! String
            }
            if let _completion = completion {
                _completion(nil)
            }
        }, errorBlock: { (error:NSError!) -> Void in
            if let _completion = completion {
                _completion(error)
            }
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
