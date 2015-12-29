//
//  VMSynchronizedAudioList.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodko on 25.06.15.
//  Copyright (c) 2015 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import VKSdkFramework
import CoreDataStorage

class VMSynchronizedAudioList: VMOfflineAudioList {
    
    var model: CDModel!
    var downloadManager: VMAudioDownloadManager!
    var user: VKUser?
    
    override var identifier: NSUUID {
        get {
            return NSUUID.vm_syncAudioListUUID
        }
        set {
            
        }
    }
    
    override init(storedAudioList: CDAudioList) {
        super.init(storedAudioList: storedAudioList)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var request: VKRequest? {
        if let user = self.user {
            return VKApi.requestWithMethod("audio.get",
                andParameters:[VK_API_OWNER_ID: user.id],
                andHttpMethod:"GET")
        } else {
            return nil
        }
    }
    
    override func reload() {
        self.synchronize()
    }
    
    func synchronize() {
        self.request?.executeWithResultBlock({ (response: VKResponse!) -> Void in
            if response != nil {
                if let vkAudios = VKAudios(dictionary:(response.json as! [NSObject : AnyObject])) {
                    
                    self.delegate?.audioListWillChange(self)
                    
                    let loadedAudios = vkAudios.items.copy() as! [VKAudio]
                    
                    var updatedAudios: [VMAudio] = []
                    var insertedAudios: [Int: VMAudio] = [:]
                        
                    for (var i: Int = 0; i < loadedAudios.count; i++) {
                        let loadedAudio = loadedAudios[i]
                        if let storedAudio = self.model.audioWithID(loadedAudio.id) {
                            let mappedLocalAudio = VMAudio(storedAudio: storedAudio)
                            updatedAudios.append(mappedLocalAudio)
                            
                            // in case audio was not already loaded for some reason (e.g. app crash)
                            
                            if !mappedLocalAudio.localFileExists {
                                self.downloadManager.downloadAudio(mappedLocalAudio)
                            }
                        } else {
                            let addedAudio = VMAudio(audio: loadedAudio)
                            updatedAudios.append(addedAudio)
                            insertedAudios[i] = addedAudio
                            self.downloadManager.downloadAudio(addedAudio)
                        }
                    }
                    
                    let commonAudios = self.audios.filter {
                        return loadedAudios.map{ $0.id }.contains($0.id)
                    }
                    
                    var movedAudios: [(audio: VMAudio, from: Int, to: Int)] = []
                    for audio in commonAudios {
                        let oldIndexOpt = self.audios.map{ $0.id }.indexOf(audio.id)
                        let newIndexOpt = updatedAudios.map{ $0.id }.indexOf(audio.id)
                        if let oldIndex = oldIndexOpt,
                            let newIndex = newIndexOpt
                            where oldIndex != newIndex {
                                movedAudios.append((audio: audio, from: oldIndex, to: newIndex))
                        }
                    }
                    
                    let audiosToRemove = self.audios.filter {
                        return !loadedAudios.map{ $0.id }.contains($0.id)
                    }
                    
                    let removedAudios = VMAudioListChangeInfo.removedAudiosForAudios(audiosToRemove, fromAudioList:self)
                    
                    let changeInfo = VMAudioListChangeInfo()
                    changeInfo.movedAudios = movedAudios
                    changeInfo.insertedAudios = insertedAudios
                    changeInfo.removedAudios = removedAudios
                    
                    self.audios = updatedAudios
                    
                    self.delegate?.autioList(self, didChangeWithInfo: changeInfo)
                }
            }
        }, errorBlock: { (error: NSError!) -> Void in
            
        })
    }
    
    override func editingEnabled() -> Bool {
        return true
    }
    
    override func addAudio(audio: VMAudio) {
        let parameters = ["audio_id": audio.id, "owner_id": audio.ownerID]
        let request = VKApi.requestWithMethod("audio.add", andParameters: parameters, andHttpMethod: "GET")
        request.executeWithResultBlock({ (vkResponse: VKResponse!) -> Void in
            if let response = vkResponse {
                // Should be new audio ID
                NSLog("Received response: \(response.json)")
                self.synchronize()
            }
        }, errorBlock: { (error:NSError!) -> Void in
            NSLog("Received error: \(error)")
        })
    }
    
    override func deleteTrackAtIndex(index: Int) {
        let audio = self.audios[index]
        
        let parameters = ["audio_id": audio.id, "owner_id": audio.ownerID]
        let request = VKApi.requestWithMethod("audio.delete", andParameters: parameters, andHttpMethod: "GET")
        request.executeWithResultBlock({ (vkResponse: VKResponse!) -> Void in
            if let response = vkResponse {
                NSLog("Received response: \(response.json)")
                // Should be 1
            }
            }, errorBlock: { (error:NSError!) -> Void in
                NSLog("Received error: \(error)")
        })
        
        super.deleteTrackAtIndex(index)
    }
    
    override func moveTrackFromIndex(index: Int, toIndex: Int) {
        
        let audio = self.audios[index]
        var parameters = ["audio_id": audio.id, "owner_id": audio.ownerID]
        
        super.moveTrackFromIndex(index, toIndex: toIndex)
        
        if toIndex > 0 {
            let beforeAudio = self.audios[toIndex - 1]
            parameters["before"] = beforeAudio.id
        }
        
        if toIndex + 1 < self.audios.count {
            let afterAudio = self.audios[toIndex + 1]
            parameters["after"] = afterAudio.id
        }
        
        let request = VKApi.requestWithMethod("audio.reorder", andParameters: parameters, andHttpMethod: "GET")
        request.executeWithResultBlock({ (vkResponse: VKResponse!) -> Void in
            if let response = vkResponse {
                NSLog("Received response: \(response.json)")
                // Should be 1
            }
            }, errorBlock: { (error:NSError!) -> Void in
                NSLog("Received error: \(error)")
        })
        
        
    }
}
