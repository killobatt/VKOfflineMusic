//
//  VMAudioList.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 24.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation

class VMOfflineAudioList: VMAudioList, NSCoding {
    
    var identifier: NSUUID
    
    init(title: NSString) {
        self.identifier = NSUUID()
        super.init()
        self.title = title
    }
    
    override var audios : Array<VMAudio> {
        didSet {
            self.totalCount = self.audios.count
        }
    }
    
    func addAudio(audio:VMAudio) {
        if find(self.audios, audio) != nil {
            return
        }
        
        var newAudios = Array<VMAudio>()
        newAudios.append(audio)
        for oldAudio in self.audios {
            newAudios.append(oldAudio)
        }
        self.audios = newAudios
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
        self.audios = aDecoder.decodeObjectForKey("audios") as! Array<VMAudio>
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
    }
    
    override func deleteTrackAtIndex(index: Int) {
        var audios = self.audios
        let audio = audios[index]
        audios.removeAtIndex(index)
        self.audios = audios
    }
}
