//
//  VMAudioListManager.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodko on 15.10.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import VK
import CoreDataStorage

class VMAudioListManager: NSObject {
   
    class var sharedInstance : VMAudioListManager {
    struct Static {
        static var onceToken : dispatch_once_t = 0
        static var instance : VMAudioListManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = VMAudioListManager()
        }
        return Static.instance!
    }
    
    override init() {
        super.init()
        self.createAudioListsDirectoryIfNeeded()
        
        self.model = CDModel(storageURL:self.audioListModelURL)
        
        self.downloadManager = VMAudioDownloadManager(delegate: self);
        
        self.addSyncAudioList()
        
        self.migrateToCoreDataStorage()
        
        self.loadOfflineAudioLists()
        
//        self.loadLegacyOfflineAudioLists()
    }
    
    deinit {
        self.saveOfflineAudioLists()
    }
    
    // MARK: - Audio List Storage
    
    var model: CDModel!
    
    var downloadManager: VMAudioDownloadManager!
    
    // MARK: - VMAudioLists
    var userAudioList: VMUserAudioList!
    var syncAudioList: VMSynchronizedAudioList! {
        didSet {
            self.syncAudioList.model = self.model
            self.syncAudioList.downloadManager = self.downloadManager
        }
    }
    var searchAudioList: VMSearchAudioList!
    var recommendationsAudioList: VMRecomendationsAudioList!
    var offlineAudioLists: Array<VMOfflineAudioList> = [] {
        willSet {
            self.willChangeValueForKey("audioLists")
            self.willChangeValueForKey("offlineAudioLists")
        }
        didSet {
            self.didChangeValueForKey("audioLists")
            self.didChangeValueForKey("offlineAudioLists")
        }
    }
//    var resentAudioList: VMAudioList!
//    var allOfflineAudioList: VMAudioList!
    
    var audioLists: Array<VMAudioList> {
        get {
            var lists: Array<VMAudioList> = []
            if self.userAudioList != nil {
                lists.append(self.userAudioList)
            }
            if self.searchAudioList != nil {
                lists.append(self.searchAudioList)
            }
            if self.recommendationsAudioList != nil {
                lists.append(self.recommendationsAudioList)
            }
            for audioList in self.offlineAudioLists {
                lists.append(audioList)
            }
            return lists
        }
    }
    
    // MARK: - VKUser
    
    var user: VKUser? {
        willSet {
            if let newUser = newValue {
                self.userAudioList = VMUserAudioList(with: newUser)
                self.userAudioList.title = "Мои аудиозаписи"
                self.userAudioList.loadNextPage(completion: nil)
                self.searchAudioList = VMSearchAudioList(searchOwn: false)
                self.searchAudioList.title = "Поиск"
                self.recommendationsAudioList = VMRecomendationsAudioList(user: newUser)
                self.recommendationsAudioList.title = "Рекомендации"
                self.recommendationsAudioList.loadNextPage(completion: nil)
                self.syncAudioList.user = newUser
                self.syncAudioList.synchronize()
                self.willChangeValueForKey("audioLists")
                self.willChangeValueForKey("offlineAudioLists")
            } else {
                self.userAudioList = nil
                self.searchAudioList = nil
            }
        }
        didSet {
            self.didChangeValueForKey("audioLists")
            self.didChangeValueForKey("offlineAudioLists")
        }
    }
    
    // MARK: - Offline audio lists
    
    private func addSyncAudioList() {
        var title = "Мои аудиозаписи (оффлайн)"
        self.model.addAudioList(title: title, identifier: NSUUID.vm_syncAudioListUUID)
    }
    
    func addOfflineAudioList(title:String) -> VMOfflineAudioList {
        var storedAudioList = self.model.addAudioList(title: title)
        var offlineAudioList = VMOfflineAudioList(storedAudioList: storedAudioList)
        self.offlineAudioLists.append(offlineAudioList)
        self.saveOfflineAudioLists()
        return offlineAudioList
    }
    
    func removeOfflineAudioList(list:VMOfflineAudioList) {
        if let index = find(self.offlineAudioLists, list) {
            self.offlineAudioLists.removeAtIndex(index)
            self.model.deleteObject(list.storedAudioList)
            let storedAudios = self.model.uniqueAudiosFromAudioList(list.storedAudioList)
            for storedAudio in storedAudios {
                self.model.deleteObject(storedAudio)
            }
//            TODO: remove only files for deleted list
//            self.removeFilesForList(list)
        }
    }
    
    private func removeFileForAudio(audio:VMAudio) {
//        if let fileName = audio.localFileName {
//            if !NSFileManager.defaultManager().removeItemAtPath(listPath, error: &error) {
//                NSLog("Could not remove list \(list.title) at path: \(listPath): \(error)")
//            }
//        }
    }
    
    private func removeFilesForList(list:VMOfflineAudioList) {
        let listPath = self.pathForLegacyList(list)
        NSLog("Removin list \(list.title) at path: \(listPath)...)")
        var error: NSError? = nil
        if !NSFileManager.defaultManager().removeItemAtPath(listPath, error: &error) {
            NSLog("Could not remove list \(list.title) at path: \(listPath): \(error)")
        }
    }
    
    func createAudioListsDirectoryIfNeeded() {
        let fileManager = NSFileManager.defaultManager()
        var audioListsDirExists = fileManager.fileExistsAtPath(self.offlineAudioListDirectoryPath)
        if (!audioListsDirExists) {
            NSLog("Creating audio list directory at path '\(self.offlineAudioListDirectoryPath)'")
            var errorPointer = NSErrorPointer()
            if (!fileManager.createDirectoryAtPath(self.offlineAudioListDirectoryPath,
                withIntermediateDirectories: true, attributes: nil, error: errorPointer)) {
                NSLog("Error creating audio list directory: \(errorPointer.memory)")
            }
        }
    }
    
    func saveLegacyOfflineAudioLists() {
        self.createAudioListsDirectoryIfNeeded()
        
        for list in self.offlineAudioLists {
            let path = self.pathForLegacyList(list)
            NSLog("Saving list '\(list.title)' with \(list.audios.count) audios to file '\(path)'...")
            NSKeyedArchiver.archiveRootObject(list, toFile: path)
        }
    }
    
    func loadLegacyOfflineAudioLists() -> [VMOfflineAudioList] {
        var offlineAudioLists: [VMOfflineAudioList] = []
        
        let fileManager = NSFileManager.defaultManager()
        var audioListsDirExists = fileManager.fileExistsAtPath(self.offlineAudioListDirectoryPath)
        if (audioListsDirExists) {
            
            NSLog("Scanning folder '\(self.offlineAudioListDirectoryPath)' for legacy lists...")
            var error: NSError? = nil
            let paths = fileManager.contentsOfDirectoryAtPath(self.offlineAudioListDirectoryPath, error: &error) as! [String]?
            if (error != nil) {
                NSLog("Error loading contents of dir \(self.offlineAudioListDirectoryPath) : \(error)")
                return []
            }
            
            if let listsFileNames = paths {
                for listFileName in listsFileNames {
                    let listPath = self.offlineAudioListDirectoryPath.stringByAppendingPathComponent(listFileName)
                    if (listPath.pathExtension != "list") {
                        continue
                    }
                    NSLog("Loading legacy list from file '\(listPath)'...")
                    var list = NSKeyedUnarchiver.unarchiveObjectWithFile(listPath) as! VMOfflineAudioList
                    offlineAudioLists.append(list)
                    NSLog("Loaded legacy list '\(list.title)' with \(list.audios.count) audios")
                }
            }
        }
        return offlineAudioLists
    }
    
    func loadOfflineAudioLists() {
        let audioLists = self.model.audioLists
        
        for storedAudioList in audioLists {
            var list: VMOfflineAudioList! = nil
            if storedAudioList.identifier == NSUUID.vm_syncAudioListUUID.UUIDString {
                self.syncAudioList = VMSynchronizedAudioList(storedAudioList: storedAudioList)
                list = self.syncAudioList
            } else {
                list = VMOfflineAudioList(storedAudioList: storedAudioList)
            }
            self.offlineAudioLists.append(list)
            NSLog("Loaded list '\(list.title)' with \(list.audios.count) audios")
        }
    }
    
    func saveOfflineAudioLists() {
        for list in self.offlineAudioLists {
            CDAudioList.storedAudioListForAudioList(list, managedObjectContext: self.model.mainContext)
        }
        self.model.save()
    }
    
    // MARK: - Paths
    
    var audioListModelURL: NSURL {
        return NSURL(fileURLWithPath: self.userDocumentsDirectoryPath.stringByAppendingPathComponent("audio-list-model.sqlite"))!
    }
    
    var userDocumentsDirectoryPath: String {
        let dirs = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,
            NSSearchPathDomainMask.UserDomainMask, true)
        return dirs[0] as! String
    }
    
    var offlineAudioListDirectoryPath: String {
        return self.userDocumentsDirectoryPath.stringByAppendingPathComponent("audio-lists")
    }
    
    func pathForLegacyList(list: VMOfflineAudioList) -> String {
        let path = self.offlineAudioListDirectoryPath.stringByAppendingPathComponent(list.identifier.UUIDString)
        return path.stringByAppendingPathExtension("list")!
    }
    
}

/// MARK: - Downloading

extension VMAudioListManager: VMAudioDownloadManagerDelegate {
    
    func downloadManager(downloadManager: VMAudioDownloadManager, didLoadFile url: NSURL, forAudioWithID audioID: NSNumber) {
        let audioFileName = audioID.stringValue.stringByAppendingPathExtension("mp3")
        let audioPath = self.offlineAudioListDirectoryPath.stringByAppendingPathComponent(audioFileName!)
        if let audioURL = NSURL(fileURLWithPath:audioPath) {
            var error: NSError?
            NSFileManager.defaultManager().moveItemAtURL(url, toURL: audioURL, error: &error)
            for list in self.offlineAudioLists {
                for audio in list.audios {
                    if audio.id == audioID {
                        audio.localFileName = audioFileName
                    }
                }
            }
        }
        self.saveOfflineAudioLists()
    }
    
    func downloadManager(downloadManager: VMAudioDownloadManager, didLoadLyrics lyrics: VMLyrics, forAudio audio: VMAudio) {
        self.saveOfflineAudioLists()
    }
}


extension VMAudio {
    var localURL: NSURL! {
        get {
            if let localFileName = self.localFileName {
                let path = VMAudioListManager.sharedInstance.offlineAudioListDirectoryPath.stringByAppendingPathComponent(localFileName as! String)
                return NSURL(fileURLWithPath: path)
            } else {
                return nil
            }
        }
    }
}

/// MARK: - Migration

extension VMAudioListManager {
    func migrateToCoreDataStorage() {
        let legacyAudioLists = self.loadLegacyOfflineAudioLists()
        for legacyList in legacyAudioLists {
            let storedAudioList = CDAudioList.storedAudioListForAudioList(legacyList,
                managedObjectContext: self.model.mainContext)
            
            let path = self.pathForLegacyList(legacyList)
            var error:NSError? = nil
            if NSFileManager.defaultManager().removeItemAtPath(path, error: &error) {
                NSLog("Removed legacy list \(legacyList.title) file \(path)")
            } else {
                NSLog("Error removing list \(legacyList.title) file: \(path)")
            }
        }
        self.model.save()
    }
}

