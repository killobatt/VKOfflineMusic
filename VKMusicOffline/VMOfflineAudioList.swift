//
//  VMAudioList.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 24.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import CoreData
import CoreDataStorage

class VMOfflineAudioList: VMAudioList, NSCoding {
    
    var identifier: NSUUID
    private(set) var storedAudioList: CDAudioList!
    
    init(storedAudioList: CDAudioList) {
        self.storedAudioList = storedAudioList
        self.identifier = NSUUID(UUIDString: storedAudioList.identifier)!
        super.init()
        self.title = storedAudioList.title
        
        var audios: [VMAudio] = []
        for storedAudio in storedAudioList.audios {
            let audio = VMAudio(storedAudio: storedAudio as! CDAudio)
            audios.append(audio)
        }
        self.audios = audios
    }
    
    override var audios : NSArray {
        didSet {
            self.totalCount = self.audios.count
        }
    }
    
    func addAudio(audio:VMAudio) {
        if self.audios.containsObject(audio) {
            return
        }
        self.audios = NSArray(object: audio).arrayByAddingObjectsFromArray(self.audios as [AnyObject])
        self.storedAudioList.addAudiosObject(CDAudio.storedAudioForAudio(audio, managedObjectContext: self.storedAudioList.managedObjectContext!))
    }
    
    // MARK: - NSCoding interface implementation
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.identifier, forKey:"identifier")
        aCoder.encodeObject(self.title, forKey:"title")
        aCoder.encodeObject(self.audios, forKey:"audios")
    }
    
    required init(coder aDecoder: NSCoder) {
        self.identifier = aDecoder.decodeObjectForKey("identifier") as! NSUUID
        super.init()
        self.title = aDecoder.decodeObjectForKey("title") as! NSString
        self.audios = aDecoder.decodeObjectForKey("audios") as! NSArray
    }

    // MARK: - VMAudio overrides
    
    override var searchResultsList: VMAudioList? {
        get {
            return VMOfflineAudioSearchList(offlineAudioList: self)
        }
    }
        
    // MARK: - Editing
    
    override func editingEnabled() -> Bool {
        return true
    }
    
    override func moveTrackFromIndex(index: Int, toIndex: Int) {
        let audios = self.audios.mutableCopy() as! NSMutableArray
        let audio = audios[index] as! VMAudio
        audios.removeObjectAtIndex(index)
        audios.insertObject(audio, atIndex:toIndex)
        self.audios = audios
        
        if var orderedAudios = self.storedAudioList.audios.mutableCopy() as? NSMutableOrderedSet {
            orderedAudios.moveObjectsAtIndexes(NSIndexSet(index: index), toIndex: toIndex)
            self.storedAudioList.audios = orderedAudios
        }
    }
    
    override func deleteTrackAtIndex(index: Int) {
        let audios = self.audios.mutableCopy() as! NSMutableArray
        let audio = audios[index] as! VMAudio
        audios.removeObjectAtIndex(index)
        self.audios = audios
        
        self.storedAudioList.removeAudiosObject(self.storedAudioList.audios[index] as! CDAudio)
    }
}
