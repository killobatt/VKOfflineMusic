//
//  VMAudioListManager.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodko on 15.10.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import VKSdkFramework
import CoreDataStorage
import CoreData

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
        
        NSFileManager.defaultManager().delegate = self
        
        self.createAudioListsDirectoryIfNeeded()
        
        self.model = CDModel(storageURL:self.audioListModelURL)
        
        self.downloadManager = VMAudioDownloadManager(delegate: self);
        
        self.addSyncAudioList()
        
        self.migrateToCoreDataStorage()
        
        self.loadOfflineAudioLists()
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
    var popularAudioList: VMPopularAudioList!
    var popularEnglishAudioList: VMPopularAudioList!
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
    
    var audioLists: [VMAudioList] {
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
            if self.popularAudioList != nil {
                lists.append(self.popularAudioList)
            }
            if self.popularEnglishAudioList != nil {
                lists.append(self.popularEnglishAudioList)
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
                
                self.popularAudioList = VMPopularAudioList()
                self.popularAudioList.title = "Популярное"
                self.popularAudioList.pageSize = 110
                self.popularAudioList.loadNextPage(completion: nil)
                
                self.popularEnglishAudioList = VMPopularAudioList()
                self.popularEnglishAudioList.title = "Popular"
                self.popularEnglishAudioList.onlyEnglish = true
                self.popularEnglishAudioList.pageSize = 180
                self.popularEnglishAudioList.loadNextPage(completion: nil)
                
                self.syncAudioList.user = newUser
//                self.syncAudioList.synchronize()
                
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
        let title = "Мои аудиозаписи (оффлайн)"
        self.model.addAudioList(title: title, identifier: NSUUID.vm_syncAudioListUUID)
    }
    
    func addOfflineAudioList(title:String) -> VMOfflineAudioList {
        let storedAudioList = self.model.addAudioList(title: title)
        let offlineAudioList = VMOfflineAudioList(storedAudioList: storedAudioList)
        self.offlineAudioLists.append(offlineAudioList)
        self.saveOfflineAudioLists()
        return offlineAudioList
    }
    
    func removeOfflineAudioList(list:VMOfflineAudioList) {
        if let index = self.offlineAudioLists.indexOf(list) {
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
//                VMLog("Could not remove list \(list.title) at path: \(listPath): \(error)")
//            }
//        }
    }
    
    private func removeFilesForList(list:VMOfflineAudioList) {
        let listURL = self.URLForLegacyList(list)
        VMLog("Removin list \(list.title) at path: \(listURL)...)")
        do {
            try NSFileManager.defaultManager().removeItemAtURL(listURL)
        } catch let error as NSError {
            VMLog("Could not remove list \(list.title) at path: \(listURL): \(error)")
            VMLogError(error)
        }
    }
    
    func createAudioListsDirectoryIfNeeded() {
        let fileManager = NSFileManager.defaultManager()
        if !self.offlineAudioListDirectoryExists {
            VMLog("Creating audio list directory at path '\(self.offlineAudioListDirectoryURL)'")
            do {
                try fileManager.createDirectoryAtURL(self.offlineAudioListDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                VMLog("Error creating audio list directory: \(error)")
                VMLogError(error)
            }
        }
    }
    
    func saveLegacyOfflineAudioLists() {
        self.createAudioListsDirectoryIfNeeded()
        
        for list in self.offlineAudioLists {
            let url = self.URLForLegacyList(list)
            VMLog("Saving list '\(list.title)' with \(list.audios.count) audios to file '\(url)'...")
            NSKeyedArchiver.archiveRootObject(list, toFile: url.absoluteString)
        }
    }
    
    func loadLegacyOfflineAudioLists() -> [VMOfflineAudioList] {
        var offlineAudioLists: [VMOfflineAudioList] = []
        
        let fileManager = NSFileManager.defaultManager()
        if (self.offlineAudioListDirectoryExists) {
            VMLog("Scanning folder '\(self.offlineAudioListDirectoryURL)' for legacy lists...")
            do {
                let listURLs = try fileManager.contentsOfDirectoryAtURL(self.offlineAudioListDirectoryURL, includingPropertiesForKeys: [], options: [])
                for listURL in listURLs {
                    if (listURL.pathExtension != "list") {
                        continue
                    }
                    VMLog("Loading legacy list from file '\(listURL)'...")
                    if let listPath = listURL.path {
                        let list = NSKeyedUnarchiver.unarchiveObjectWithFile(listPath) as! VMOfflineAudioList
                        offlineAudioLists.append(list)
                        VMLog("Loaded legacy list '\(list.title)' with \(list.audios.count) audios")
                    }
                }
            } catch let error as NSError {
                VMLog("Error loading contents of dir \(self.offlineAudioListDirectoryURL) : \(error)")
                VMLogError(error)
                return []
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
            VMLog("Loaded list '\(list.title)' with \(list.audios.count) audios")
        }
    }
    
    func saveOfflineAudioLists() {
        let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.parentContext = self.model.mainContext
        context.performBlock() {
            for list in self.offlineAudioLists {
                CDAudioList.storedAudioListForAudioList(list, managedObjectContext: context)
            }
            
            do {
                try context.save()
            } catch let error as NSError {
                VMLog("Error saving child context: \(error)")
                VMLogError(error)
            }
            
            self.model.mainContext.performBlockAndWait() {
                self.model.save()
            }
        }
    }
    
    // MARK: - Paths
    
    var audioListModelURL: NSURL {
        return self.userDocumentsDirectoryURL.URLByAppendingPathComponent("audio-list-model.sqlite")
    }
    
    var userDocumentsDirectoryURL: NSURL {
        let dirs = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,
            NSSearchPathDomainMask.UserDomainMask, true)
        return NSURL(fileURLWithPath: dirs[0])
    }
    
    var offlineAudioListDirectoryURL: NSURL {
        return self.userDocumentsDirectoryURL.URLByAppendingPathComponent("audio-lists")
    }
    
    var offlineAudioListDirectoryExists: Bool {
        var isDirectory: ObjCBool = false
        if let path = self.offlineAudioListDirectoryURL.path where NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDirectory) {
            return isDirectory.boolValue
        } else {
            return false
        }
    }
    
    func URLForAudioID(audioID: String) -> NSURL {
        return self.offlineAudioListDirectoryURL.URLByAppendingPathComponent(audioID).URLByAppendingPathExtension("mp3")
    }
    
    func URLForLegacyList(list: VMOfflineAudioList) -> NSURL {
        let url = self.offlineAudioListDirectoryURL.URLByAppendingPathComponent(list.identifier.UUIDString)
        return url.URLByAppendingPathExtension("list")
    }
    
}

/// MARK: - Downloading

extension VMAudioListManager: VMAudioDownloadManagerDelegate {
    
    func downloadManager(downloadManager: VMAudioDownloadManager, didLoadFile url: NSURL, forAudioWithID audioID: NSNumber) {
        
        VMLog("downloadManager audio: \(audioID) was loaded to temp file: \(url)")
        let audioURL = self.URLForAudioID(audioID.stringValue)
        
        do {
            try NSFileManager.defaultManager().moveItemAtURL(url, toURL: audioURL)
            VMLog("downloadManager audio: \(audioID) was copied to file: \(audioURL)")
            
            let allAudios = self.offlineAudioLists.reduce([]) { result, list in result + list.audios }
            let audiosToUpdate = allAudios.filter { audio in audio.id == audioID }
            for audio in audiosToUpdate {
                audio.localFileName = audioID.stringValue
            }
            self.saveOfflineAudioLists()
        } catch let error as NSError {
            VMLog("Error moving item: \(error)")
            VMLogError(error)
        } catch _ {
            VMLog("Unknown shit happened")
        }
        
    }
    
    func downloadManager(downloadManager: VMAudioDownloadManager, didLoadLyrics lyrics: VMLyrics, forAudio audio: VMAudio) {
        self.saveOfflineAudioLists()
    }
}

extension VMAudioListManager: NSFileManagerDelegate {
    func fileManager(fileManager: NSFileManager, shouldProceedAfterError error: NSError, movingItemAtURL srcURL: NSURL, toURL dstURL: NSURL) -> Bool {
        if error.code == NSFileWriteFileExistsError {
            VMLog("will overwrite file at path: \(dstURL)")
            return true
        }
        return false
    }
}

extension VMAudio {
    var localURL: NSURL? {
        get {
            if let localFileName = self.localFileName {
                return VMAudioListManager.sharedInstance.URLForAudioID(localFileName as String)
            } else {
                return nil
            }
        }
    }
    
    var localFileExists: Bool {
        if let path = self.localURL?.path where
            NSFileManager.defaultManager().fileExistsAtPath(path) {
                return true
        } else {
            return false
        }
    }
}

/// MARK: - Migration

extension VMAudioListManager {
    func migrateToCoreDataStorage() {
        let legacyAudioLists = self.loadLegacyOfflineAudioLists()
        for legacyList in legacyAudioLists {
            CDAudioList.storedAudioListForAudioList(legacyList, managedObjectContext: self.model.mainContext)
            
            let path = self.URLForLegacyList(legacyList)
            do {
                try NSFileManager.defaultManager().removeItemAtURL(path)
                VMLog("Removed legacy list \(legacyList.title) file \(path)")
            } catch let error {
                VMLog("Error removing list \(legacyList.title) file: \(path), error: \(error)")
            }
        }
        self.model.save()
    }
}

