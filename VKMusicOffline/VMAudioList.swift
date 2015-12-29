//
//  VMAudioList.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 20.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import VKSdkFramework

class VMAudioList: NSObject {
    
    dynamic var audios : [VMAudio] = []
    
    var title : NSString!
   
    var searchResultsList: VMAudioList? {
        get {
            return nil
        }
    }
    
    var delegate: VMAudioListDelegate?
    
    subscript(index: Int) -> VMAudio {
        get {
            return self.audios[index]
        }
    }
    
    // number of audios in loaded part of list
    var count: Int {
        get {
            return self.audios.count
        }
    }
    
    // nuber of audios in both loaded and unloaded part of list
    dynamic var totalCount: Int = 0 // {
    
    func hasNextPage() -> Bool { return false }
    func loadNextPage(completion completion:((NSError!) -> Void)?) -> Void { }
    func reload() {}
}

class VMAudioListChangeInfo {
    var insertedAudios: [Int: VMAudio] = [:]
    var removedAudios:  [Int: VMAudio] = [:]
    var movedAudios: [(audio: VMAudio, from: Int, to: Int)] = []
    
    static func removedAudiosForAudios(audios: [VMAudio], fromAudioList audioList:VMAudioList) -> [Int: VMAudio] {
        return audios.reduce([Int: VMAudio]()) { (var dictionary: [Int: VMAudio], audio: VMAudio) -> [Int: VMAudio] in
            if let index = audioList.audios.indexOf(audio) {
                dictionary[index] = audio
            }
            return dictionary
        }
    }
}

protocol VMAudioListDelegate {
    func audioListWasReloaded(audioList: VMAudioList)
    func audioListWillChange(audioList: VMAudioList)
    func autioList(audioList: VMAudioList, didChangeWithInfo changeInfo: VMAudioListChangeInfo)
}

// Editable list
extension VMAudioList {
    
    func moveTrackFromIndex(index:Int, toIndex:Int) { }
    func deleteTrackAtIndex(index:Int) { }
    func deleteAudio(audio: VMAudio) { }
    
    func editingEnabled() -> Bool { return false }
    
}
