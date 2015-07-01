//
//  VMOfflineAudioList+CDAudioList.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodko on 21.06.15.
//  Copyright (c) 2015 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import CoreData
import CoreDataStorage

extension CDAudioList {
    
    class func storedAudioListForAudioList(audioList: VMOfflineAudioList, managedObjectContext context: NSManagedObjectContext) -> CDAudioList {
        let request = NSFetchRequest(entityName: self.entityName())
        request.predicate = NSPredicate(format: "identifier = %@", audioList.identifier.UUIDString)
        
        var error: NSError? = nil
        var storedAudioList: CDAudioList! = context.executeFetchRequest(request, error: &error)?.first as! CDAudioList!
        if storedAudioList == nil {
            storedAudioList = CDAudioList(managedObjectContext: context)
        }
        storedAudioList.identifier = audioList.identifier.UUIDString
        storedAudioList.title = audioList.title! as String
        
        var storedAudios: NSMutableOrderedSet = NSMutableOrderedSet(array: [])
        for audio in audioList.audios {
            let storedAudio = CDAudio.storedAudioForAudio(audio, managedObjectContext: context)
            storedAudios.addObject(storedAudio)
        }
        storedAudioList.audios = storedAudios
        return storedAudioList
    }
    
}


