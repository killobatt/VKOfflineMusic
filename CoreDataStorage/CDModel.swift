//
//  CDModel.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodko on 21.06.15.
//  Copyright (c) 2015 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import CoreData

public class CDModel: NSObject {
   
    public private(set) var persistentStoreCoordinator: NSPersistentStoreCoordinator!
    public private(set) var model: NSManagedObjectModel!
    public private(set) var mainContext: NSManagedObjectContext!
    
    public var modelFileName: String {
        return "\(self.modelFileNameWithoutExtension)\(self.modelFileExtension)"
    }
    
    public var modelFileNameWithoutExtension: String {
        return "Model"
    }
    
    public var modelFileExtension: String {
        return "momd"
    }
    
    public var modelFileURL: NSURL? {
        if let modelPath = NSBundle(forClass: self.dynamicType).pathForResource(self.modelFileNameWithoutExtension,
            ofType: self.modelFileExtension) {
                return NSURL(string: modelPath)
        } else {
            return nil
        }
    }
    
    public init(storageURL:NSURL) {
        super.init()
        NSLog("Using model \(self.modelFileURL)")
        self.model = NSManagedObjectModel(contentsOfURL: self.modelFileURL!)
        
        self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        NSLog("Using persistentStore: \(storageURL)")
        if let _ = try? self.persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType,
            configuration: nil, URL: storageURL, options: nil) {
            self.mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            self.mainContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        }
    }
    
    public func save() {
        do {
            try self.mainContext.save()
            NSLog("Model saved.")
        } catch let error as NSError {
            NSLog("Error saving model: \(error)")
        }
    }
    
    private func executeFetchRequest(fetchRequest: NSFetchRequest) -> [NSManagedObject] {
        do {
            let audioLists = try self.mainContext.executeFetchRequest(fetchRequest)
            return audioLists as! [NSManagedObject]
        } catch let error as NSError {
            NSLog("Fetch request \(fetchRequest) for \(fetchRequest.entityName) failed with error: \(error)")
            return []
        }
    }
    
    public func deleteObject(object: NSManagedObject) {
        if object is CDAudioList {
            self.deleteAudioList(object as! CDAudioList)
        } else if object is CDAudio {
            self.deleteAudio(object as! CDAudio)
        } else {
            self.mainContext.deleteObject(object)
        }
    }
}

/// MARK: - AudioList

public extension CDModel {
    
    public func addAudioList(title title: String, identifier:NSUUID) -> CDAudioList {
        if let storedAudioList = self.audioListWithIdentifier(identifier) {
            return storedAudioList
        }
        
        let storedAudioList = CDAudioList(managedObjectContext: self.mainContext)
        storedAudioList.title = title as String
        storedAudioList.identifier = identifier.UUIDString
        return storedAudioList
    }
    
    public func addAudioList(title title: String) -> CDAudioList {
        return self.addAudioList(title: title, identifier: NSUUID())
    }
    
    private func deleteAudioList(list: CDAudioList) {
        let audiosToDelete = self.uniqueAudiosFromAudioList(list)
        for audio in audiosToDelete {
            self.deleteAudio(audio)
        }
        self.mainContext.deleteObject(list)
    }
    
    public var audioLists: [CDAudioList] {
        return self.executeFetchRequest(self.audioListFetchRequest) as! [CDAudioList]
    }
    
    public func audioListWithIdentifier(identifier: NSUUID) -> CDAudioList? {
        let fetchRequest = NSFetchRequest(entityName: CDAudioList.entityName())
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier.UUIDString)
        return (self.executeFetchRequest(fetchRequest) as! [CDAudioList]).first
    }
    
    public var audioListFetchRequest: NSFetchRequest {
        return NSFetchRequest(entityName: CDAudioList.entityName())
    }
}

/// MARK: - Audio

public extension CDModel {
    
    public var allAudiosFetchRequest: NSFetchRequest {
        return NSFetchRequest(entityName: CDAudio.entityName())
    }
    
    public var allAudios: [CDAudio] {
        return self.executeFetchRequest(self.allAudiosFetchRequest) as! [CDAudio]
    }
    
    public func audioWithID(id: NSNumber) -> CDAudio? {
        let fetchRequest = NSFetchRequest(entityName: CDAudio.entityName())
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        return (self.executeFetchRequest(fetchRequest) as! [CDAudio]).first
    }
    
    /// Audios contained in given list only
    public func uniqueAudiosFromAudioList(list: CDAudioList) -> [CDAudio] {
        let audios = list.audios.array as! Array<CDAudio>
        return audios.filter{ $0.lists.count == 1 }
    }
    
    private func deleteAudio(audio: CDAudio) {
        self.mainContext.deleteObject(audio)
    }
}
