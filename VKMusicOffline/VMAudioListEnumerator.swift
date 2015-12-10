//
//  VMAudioListEnumerator.swift
//  VKMusicOffline
//
//  Created by Guest on 18/11/14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import Darwin


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
    
    private static let typeTable: [VMAudioListEnumeratorType: VMAudioListEnumerator.Type] = [
        .CycledDirect : VMCycledDirectAudioListEnumerator.self,
        .CycledRandom : VMCycledRandomAudioListEnumerator.self,
    ]
    
    static func rangeEnumeratorClassWithType(type: VMAudioListEnumeratorType) -> VMAudioListEnumerator.Type {
        return self.typeTable[type]!
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

class VMCycledRandomAudioListEnumerator: NSObject, VMAudioListEnumerator {
    
    private weak var audioList: VMAudioList?
    var currentIndex: Int
    var randomRearrangedIndexes: [Int] = []
    
    func rearrangeWithCurrentIndex(currentIndex: Int) {
        if let audioList = self.audioList {
            var indexes = audioList.audios.enumerate().map { (index, audio) in return index }
            var rearrangedIndexes: [Int] = []
            
            if (indexes.count > currentIndex) {
                indexes.removeAtIndex(currentIndex)
            }
            
            while indexes.count > 0 {
                let randomIndex = Int(arc4random_uniform(UInt32(indexes.count)))
                rearrangedIndexes.append(indexes[randomIndex])
                indexes.removeAtIndex(randomIndex)
            }
            self.randomRearrangedIndexes = rearrangedIndexes
        }
    }
    
    convenience required init(audioList: VMAudioList) {
        self.init(audioList: audioList, currentIndex: 0)
    }
    
    required init(audioList: VMAudioList, currentIndex: Int) {
        self.audioList = audioList
        self.currentIndex = currentIndex
        
        super.init()
        self.audioList?.addObserver(self, forKeyPath: "audios", options: [.New, .Initial], context: nil)
    }
    
    deinit {
        self.audioList?.removeObserver(self, forKeyPath: "audios")
    }
    
    var nextIndex: Int {
        if (self.randomRearrangedIndexes.count == 0) {
            self.rearrangeWithCurrentIndex(self.currentIndex)
        }
        if let first = self.randomRearrangedIndexes.first {
            self.randomRearrangedIndexes.removeFirst()
            self.randomRearrangedIndexes.append(self.currentIndex)
            self.currentIndex = first
        }
        return self.currentIndex
    }
    
    var previousIndex: Int {
        if (self.randomRearrangedIndexes.count == 0) {
            self.rearrangeWithCurrentIndex(self.currentIndex)
        }
        if let last = self.randomRearrangedIndexes.last {
            self.randomRearrangedIndexes.removeLast()
            self.randomRearrangedIndexes.insert(self.currentIndex, atIndex: 0)
            self.currentIndex = last
        }
        return self.currentIndex
    }
    
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if object === self.audioList && keyPath == "audios" {
            if let newCount = self.audioList?.audios.count {
                if self.currentIndex >= newCount {
                    self.currentIndex = 0
                }
                
                if newCount > 0 {
                    self.rearrangeWithCurrentIndex(self.currentIndex)
                }
            }
        }
    }
}
