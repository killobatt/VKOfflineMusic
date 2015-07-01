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
    
    override var audios : [VMAudio] {
        didSet {
            self.totalCount = self.audios.count
        }
    }
    
    func addAudio(audio:VMAudio) {
        self.insertAudio(audio, atIndex: self.audios.count)
//        if let _ = find(self.audios, audio) {
//            return
//        }
//        var newAudios = self.audios
//        newAudios.append(audio)
//        self.audios = newAudios
//        self.storedAudioList.addAudiosObject(CDAudio.storedAudioForAudio(audio, managedObjectContext: self.storedAudioList.managedObjectContext!))
    }
    
    func insertAudio(audio: VMAudio, atIndex index:Int) {
        if let oldIndex = find(self.audios, audio) {
            self.moveTrackFromIndex(oldIndex, toIndex: index)
            return
        }
        
        var newAudios = self.audios
        newAudios.insert(audio, atIndex: index)
        self.audios = newAudios
        
        let storedAudio = CDAudio.storedAudioForAudio(audio, managedObjectContext: self.storedAudioList.managedObjectContext!)
        var storedAudios = self.storedAudioList.audios.mutableCopy() as! NSMutableOrderedSet
        storedAudios.insertObject(storedAudio, atIndex: index)
        self.storedAudioList.audios = storedAudios
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
        self.audios = aDecoder.decodeObjectForKey("audios") as! [VMAudio]
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
        var audios = self.audios
        let audio = audios[index]
        audios.removeAtIndex(index)
        audios.insert(audio, atIndex: toIndex)
        self.audios = audios
        
        if var orderedAudios = self.storedAudioList.audios.mutableCopy() as? NSMutableOrderedSet {
            orderedAudios.moveObjectsAtIndexes(NSIndexSet(index: index), toIndex: toIndex)
            self.storedAudioList.audios = orderedAudios
        }
    }
    
    override func deleteTrackAtIndex(index: Int) {
        var audios = self.audios
        let audio = audios[index]
        audios.removeAtIndex(index)
        self.audios = audios
        
        self.storedAudioList.deleteAudio(self.storedAudioList.audios[index] as! CDAudio)
    }
    
    override func deleteAudio(audio: VMAudio) {
        if let index = find(self.audios, audio) {
            self.deleteTrackAtIndex(index)
        }
    }
}
