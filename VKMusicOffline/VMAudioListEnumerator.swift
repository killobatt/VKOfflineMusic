//
//  VMAudioListEnumerator.swift
//  VKMusicOffline
//
//  Created by Guest on 18/11/14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation

// Player enumerates audio list.
// Enumeration logic can be complex besause 
//  - audio list can change while playing
//  - in future we want have shuffle playing (random enumerator)
// So we encupsulte it here
class VMAudioListEnumerator: NSObject {
    
    var nextObject: VMAudio! {
        get {
            return self.audioList[self.nextObjectIndex]
        }
    }
    
    var previousObject: VMAudio! {
        get {
            return self.audioList[self.previousObjectIndex]
        }
    }
    
    var nextObjectIndex: Int {
        get {
            return (self.currentObjectIndex + 1) % self.audioList.count
        }
    }
    
    var previousObjectIndex: Int {
        get {
            return (self.currentObjectIndex - 1) % self.audioList.count
        }
    }
    
    private(set) var currentObject: VMAudio!
    var currentObjectIndex: Int! {
        get {
            return find(self.audioList.audios, self.currentObject)
        }
    }
    
    
    // MARK: - Init
    
    init(audioList: VMAudioList, indexOfCurrentObject:Int) {
        self.audioList = audioList
        self.currentObject = self.audioList[indexOfCurrentObject]
        super.init()
    }
    
    // MARK: - Private
    
    private var audioList: VMAudioList
    
    
}
