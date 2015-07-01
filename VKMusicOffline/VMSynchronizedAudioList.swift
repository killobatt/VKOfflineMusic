//
//  VMSynchronizedAudioList.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodko on 25.06.15.
//  Copyright (c) 2015 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import VK
import CoreDataStorage

class VMSynchronizedAudioList: VMOfflineAudioList {
    
    var model: CDModel!
    var downloadManager: VMAudioDownloadManager!
    
    init(model: CDModel, storedAudioList: CDAudioList) {
        self.model = model
        super.init(storedAudioList: storedAudioList)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var request: VKRequest! = nil
    
    func synchronize() {
        self.request.executeWithResultBlock({ (response: VKResponse!) -> Void in
            if response != nil {
                if let vkAudios = VKAudios(dictionary:(response.json as! [NSObject : AnyObject])) {
                    
                    var audiosToDelete: [VMAudio] = []
                    
                    let loadedAudios = vkAudios.items.copy() as! [VKAudio]
                    let storedAudios = self.storedAudioList.audios
                    
                    var updatedAudios: [VMAudio] = []
                    var audiosToInsert: [Int: VMAudio] = [:]
                        
                    for (var i: Int = 0; i < loadedAudios.count; i++) {
                        let loadedAudio = loadedAudios[i]
                        if let storedAudio = self.model.audioWithID(loadedAudio.id) {
                            updatedAudios.append(VMAudio(storedAudio: storedAudio))
                        } else {
                            // TODO: download audio
                            let addedAudio = VMAudio(audio: loadedAudio)
                            updatedAudios.append(addedAudio)
                            audiosToInsert[i] = addedAudio
                        }
                    }
                    
                    var commonAudios = self.audios.filter {
                        return find(loadedAudios.map{ $0.id }, $0.id) != nil
                    }
                    
                    var audiosToMove: [(audio: VMAudio, from: Int, to: Int)] = []
                    for audio in commonAudios {
                        if let oldIndex = find(self.audios, audio), newIndex = find(updatedAudios, audio)
                            where oldIndex != newIndex {
                                audiosToMove.append((audio: audio, from: oldIndex, to: newIndex))
                        }
                    }
                    
                    var audiosToRemove = self.audios.filter {
                        return find(loadedAudios.map{ $0.id }, $0.id) == nil
                    }
                    
                    // TODO: use insertedAudios, audiosToMove and audiosToRemove to make updates
                    
                    self.audios = updatedAudios
                }
            }
        }, errorBlock: { (error: NSError!) -> Void in
            
        })
    }
    
    
}
