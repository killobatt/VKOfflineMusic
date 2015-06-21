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
   
    private(set) var persistentStoreCoordinator: NSPersistentStoreCoordinator!
    private(set) var model: NSManagedObjectModel!
    private(set) var mainContext: NSManagedObjectContext!
    
    var modelFileName: String {
        get {
            return "Model.momd"
        }
    }
    
    var modelFileURL: NSURL? {
        if let modelPath = NSBundle(forClass: self.dynamicType).pathForResource(self.modelFileName.stringByDeletingPathExtension,
            ofType: self.modelFileName.pathExtension) {
                return NSURL(string: modelPath)
        } else {
            return nil
        }
    }
    
    public init(storageURL:NSURL) {
        super.init()
        self.model = NSManagedObjectModel(contentsOfURL: self.modelFileURL!)
        
        self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        var error: NSError? = nil
        let store = self.persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType,
            configuration: nil, URL: storageURL, options: nil, error: &error)
        
        if (store != nil) {
            self.mainContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            self.mainContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        } else {
            NSLog("Error adding persistent store: \(error)")
        }
    }
    
    public var audioLists: [CDAudioList] {
        get {
            var error: NSError? = nil
            if var audioLists = self.mainContext.executeFetchRequest(self.audioListFetchRequest, error: &error) {
                return audioLists as! [CDAudioList]
            } else {
                NSLog("Error fetching audio lists: \(error)")
                return []
            }
        }
    }
    
    public var audioListFetchRequest: NSFetchRequest {
        get {
            var fetchRequest = NSFetchRequest(entityName: CDAudioList.entityName())
            return fetchRequest
        }
    }

}
