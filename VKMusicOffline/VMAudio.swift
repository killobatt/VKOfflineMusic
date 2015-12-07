//
//  VMAudio.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 20.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import VK
import CoreDataStorage

class VMAudio: NSObject, NSCoding {
    var id : NSNumber!
    var ownerID : NSNumber!
    var artist : NSString!
    var title : NSString!
    var URL : NSURL!
    var localFileName : NSString!
    var lyrics: VMLyrics? = nil
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
    var formattedTitle: NSString {
        get {
            return "\(self.artist) - \(self.title)"
        }
    }
    
    override init() {
        self.duration = 0
    }
    
    init(audio: VKAudio) {
        self.id = audio.id
        self.ownerID = audio.owner_id
        self.artist = audio.artist
        self.title = audio.title
        if (audio.url != nil) {
            self.URL = NSURL(string: audio.url)
        }
        self.albumID = audio.album_id
        self.genreID = audio.genre_id
        if (audio.duration != nil) {
            self.duration = audio.duration.integerValue
        } else {
            self.duration = 0
        }
        super.init()
        if (audio.lyrics_id != nil) {
            self.lyrics = VMLyrics(audio: self, identifier: audio.lyrics_id)
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
    
    required init?(coder aDecoder: NSCoder) {
        self.id = NSNumber(int: aDecoder.decodeIntForKey("id"))
        self.ownerID = NSNumber(int: aDecoder.decodeIntForKey("ownerID"))
        self.duration = Int(aDecoder.decodeIntForKey("duration"))
        self.artist = aDecoder.decodeObjectForKey("artist") as! NSString!
        self.title = aDecoder.decodeObjectForKey("title") as! NSString!
        self.URL = aDecoder.decodeObjectForKey("URL") as! NSURL!
        self.localFileName = aDecoder.decodeObjectForKey("localFileName") as! NSString!
        self.albumID = aDecoder.decodeObjectForKey("albumID") as! NSNumber!
        super.init()
        if let lyrics = aDecoder.decodeObjectForKey("lyrics") as? VMLyrics {
            self.lyrics = lyrics
            self.lyrics!.audio = self
        }
    }
    
    // MARK: - Equatable
    
}

func ==(lhs: VMAudio, rhs: VMAudio) -> Bool {
    return lhs.id == rhs.id
}


extension VMAudio {
    
    private var requestParameters: [NSObject : AnyObject] {
        return ["audios":"\(self.ownerID)_\(self.id)"]
    }
    
    private var request: VKRequest {
        return VKRequest(method: "audio.getById",
            andParameters: self.requestParameters,
            andHttpMethod: "GET")
    }
    
    func refreshURL(completion:(audio:VMAudio?, error:NSError?) -> ()) {
        self.request.executeWithResultBlock({ (response: VKResponse!) -> Void in
            
            var audios : VKAudios! = nil
            if let audioJSONDictionary = response.json as? [NSObject : AnyObject] {
                audios = VKAudios(dictionary: audioJSONDictionary)
            } else if let audioJSONArray = response.json as? [AnyObject] {
                audios = VKAudios(array: audioJSONArray)
            }
            
            if (audios.count == 0) {
                completion(audio: nil, error: NSError(domain:NSCocoaErrorDomain, code:-1, userInfo: [NSLocalizedDescriptionKey: "No VKAudios found in response: \(response.json)"]))
                return
            }
            
            if let audio = audios.objectAtIndex(0) as? VKAudio,
                url = audio.url {
                    self.URL = NSURL(string: url)
                    completion(audio: self, error: nil)
            } else {
                completion(audio: nil, error: NSError(domain:NSCocoaErrorDomain, code:-1, userInfo: [NSLocalizedDescriptionKey: "could not parse object VKAudio from response: \(response.json)"]))
            }
            }) { (error: NSError!) -> Void in
                completion(audio: nil, error: error)
        }
    }
    
}


