//
//  VMLyrics+CSLyrics.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodko on 21.06.15.
//  Copyright (c) 2015 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import CoreData
import CoreDataStorage

class VMLyrics_CSLyrics: VMAudio {
   
}

extension CDLyrics {
    
    class func storedLyricsForLyrics(lyrics: VMLyrics, storedAudio: CDAudio, managedObjectContext context: NSManagedObjectContext) -> CDLyrics {
        let request = NSFetchRequest(entityName: self.entityName())
        request.predicate = NSPredicate(format: "id = %@", lyrics.id)
        
        var error: NSError? = nil
        var storedLyrics = context.executeFetchRequest(request, error: &error)?.first as! CDLyrics!
        if storedLyrics == nil {
            storedLyrics = CDLyrics(managedObjectContext: context)
        }
        
        storedLyrics.id = lyrics.id
        storedLyrics.audio = storedAudio
        storedLyrics.text = lyrics.text
        return storedLyrics
    }
    
}
