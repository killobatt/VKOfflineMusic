//
//  VMAudio+CDAudio.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodko on 21.06.15.
//  Copyright (c) 2015 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import CoreDataStorage
import CoreData

extension VMAudio {
    
    convenience init(storedAudio: CDAudio) {
        self.init()
        self.id = storedAudio.id
        self.ownerID = storedAudio.ownerID
        self.artist = storedAudio.artist
        self.title = storedAudio.title
        if let remoteURLString = storedAudio.remoteURLString {
            self.URL = NSURL(string: remoteURLString)
        }
        self.localFileName = storedAudio.localFileName
        self.albumID = storedAudio.albumID
        self.genreID = storedAudio.genreID
        if let duration = storedAudio.duration?.integerValue {
            self.duration = duration
        } else {
            self.duration = 0
        }
        if let lyrics = storedAudio.lyrics {
            self.lyrics = VMLyrics(audio:self, storedLyrics: lyrics)
        }
    }
    
}

extension CDAudio {
    
    class func storedAudioForAudio(audio: VMAudio, managedObjectContext context: NSManagedObjectContext) -> CDAudio {
        let request = NSFetchRequest(entityName: self.entityName())
        request.predicate = NSPredicate(format: "id = %@", audio.id)
        
        var error: NSError? = nil
        var storedAudio = context.executeFetchRequest(request, error: &error)?.first as! CDAudio!
        if storedAudio == nil {
            var storedAudio = CDAudio(managedObjectContext: context)
        }
        
        storedAudio.id = audio.id
        storedAudio.ownerID = audio.ownerID
        if let artist = audio.artist {
            storedAudio.artist = artist as String
        }
        if let title = audio.title {
            storedAudio.title = title as String
        }
        storedAudio.remoteURLString = audio.URL.absoluteString
        storedAudio.localFileName = audio.localFileName as String?
        storedAudio.albumID = audio.albumID
        storedAudio.genreID = audio.genreID
        storedAudio.duration = NSNumber(integer: audio.duration)
        if let lyrics = audio.lyrics {
            storedAudio.lyrics = CDLyrics.storedLyricsForLyrics(lyrics, storedAudio: storedAudio,
                managedObjectContext: context)
        }
        return storedAudio
    }
    
}
