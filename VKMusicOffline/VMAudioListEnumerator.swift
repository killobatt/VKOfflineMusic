//
//  VMAudioListEnumerator.swift
//  VKMusicOffline
//
//  Created by Guest on 18/11/14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation


protocol VMAudioListEnumerator {
    var nextIndex: Int { get }
    var previousIndex: Int { get }
    var currentIndex: Int { get set }
    
    init(audioList: VMAudioList)
    init(audioList: VMAudioList, currentIndex: Int)
}

enum VMAudioListEnumeratorType {
    case CycledDirect
    case CycledRandom
}

class VMAudioListEnumeratorFactory {
    
    private static let typeTable = [
        VMAudioListEnumeratorType.CycledDirect : VMCycledDirectAudioListEnumerator.self
    ]
    
    func rangeEnumeratorClassWithType(type: VMAudioListEnumeratorType) -> AnyClass {
        return self.dynamicType.typeTable[type]!
    }
}

class VMCycledDirectAudioListEnumerator: VMAudioListEnumerator {
    
    private weak var audioList: VMAudioList?
    var currentIndex: Int
    
    convenience required init(audioList: VMAudioList) {
        self.init(audioList: audioList, currentIndex: 0)
    }
    
    required init(audioList: VMAudioList, currentIndex: Int) {
        self.audioList = audioList
        self.currentIndex = currentIndex
    }
    
    var nextIndex: Int {
        if let audioList = self.audioList {
            self.currentIndex = (self.currentIndex + 1) % audioList.count
            return self.currentIndex
        } else {
            return 0
        }
    }
    
    var previousIndex: Int {
        if let audioList = self.audioList {
            self.currentIndex = (self.currentIndex - 1 + audioList.count) % audioList.count
            return self.currentIndex
        } else {
            return 0
        }
    }
}

//class VMCycledRandomRangeEnumerator: VMRangeEnumerator {
//    
//    required init(fromIndex: Int, toIndex: Int) {
//        
//    }
//    
//    var nextIndex: Int {
//        return (self.currentObjectIndex + 1) % self.audioList.count
//    }
//    var previousIndex: Int {
//        return 0
//    }
//    
//}

// Player enumerates audio list.
// Enumeration logic can be complex besause 
//  - audio list can change while playing
//  - in future we want have shuffle playing (random enumerator)
// So we encupsulte it here
//class VMAudioListEnumerator: NSObject {
//    
//    var nextObject: VMAudio! {
//        get {
//            return self.audioList[self.nextObjectIndex]
//        }
//    }
//    
//    var previousObject: VMAudio! {
//        get {
//            return self.audioList[self.previousObjectIndex]
//        }
//    }
//    
//    var nextObjectIndex: Int {
//        get {
//            return (self.currentObjectIndex + 1) % self.audioList.count
//        }
//    }
//    
//    var previousObjectIndex: Int {
//        get {
//            return (self.currentObjectIndex - 1) % self.audioList.count
//        }
//    }
//    
//    private(set) var currentObject: VMAudio!
//    var currentObjectIndex: Int! {
//        get {
//            return self.audioList.audios.indexOf(self.currentObject)
//        }
//    }
//    
//    
//    // MARK: - Init
//    
//    init(audioList: VMAudioList, indexOfCurrentObject:Int) {
//        self.audioList = audioList
//        self.currentObject = self.audioList[indexOfCurrentObject]
//        super.init()
//    }
//    
//    // MARK: - Private
//    
//    private var audioList: VMAudioList
//    
//    
//}
