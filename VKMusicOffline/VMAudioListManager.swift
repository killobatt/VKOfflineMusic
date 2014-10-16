//
//  VMAudioListManager.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodko on 15.10.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import VK

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
        self.loadOfflineAudioLists()
    }
    
    // MARK: - VMAudioLists
    var userAudioList: VMUserAudioList!
    var searchAudioList: VMSearchAudioList!
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
    
    func addOfflineAudioList(title:NSString) -> VMOfflineAudioList {
        var offlineAudioList = VMOfflineAudioList(title: title)
        self.offlineAudioLists.append(offlineAudioList)
        self.saveOfflineAudioLists()
        return offlineAudioList
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
    
    func saveOfflineAudioLists() {
        self.createAudioListsDirectoryIfNeeded()
        
        for list in self.offlineAudioLists {
            let path = self.pathForList(list)
            NSLog("Saving list '\(list.title)' with \(list.audios.count) audios to file '\(path)'...")
            NSKeyedArchiver.archiveRootObject(list, toFile: path)
        }
    }
    
    func loadOfflineAudioLists() {
        self.offlineAudioLists = []
        
        let fileManager = NSFileManager.defaultManager()
        var audioListsDirExists = fileManager.fileExistsAtPath(self.offlineAudioListDirectoryPath)
        if (audioListsDirExists) {
            
            NSLog("Scanning folder '\(self.offlineAudioListDirectoryPath)' for lists...")
            var error: NSError? = nil
            let paths = fileManager.contentsOfDirectoryAtPath(self.offlineAudioListDirectoryPath, error: &error)
            if (error != nil) {
                NSLog("Error loading contents of dir \(self.offlineAudioListDirectoryPath) : \(error)")
                return
            }
            
            if let listsFileNames = paths {
                for listFileName in listsFileNames {
                    let listPath = self.offlineAudioListDirectoryPath.stringByAppendingPathComponent(listFileName as NSString)
                    if (listPath.pathExtension != "list") {
                        continue
                    }
                    NSLog("Loading list from file '\(listPath)'...")
                    var list = NSKeyedUnarchiver.unarchiveObjectWithFile(listPath) as VMOfflineAudioList
                    self.offlineAudioLists.append(list)
                    NSLog("Loaded list '\(list.title)' with \(list.audios.count) audios")
                }
            }
        }
    }
    
    // MARK: - Paths
    
    var offlineAudioListDirectoryPath: NSString {
        get {
            let dirs = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,
                NSSearchPathDomainMask.UserDomainMask, true)
            let userDocumentsDirectory = dirs[0] as NSString
            return userDocumentsDirectory.stringByAppendingPathComponent("audio-lists")
        }
    }
    
    func pathForList(list: VMOfflineAudioList) -> NSString {
        let path = self.offlineAudioListDirectoryPath.stringByAppendingPathComponent(list.identifier.UUIDString)
        return path.stringByAppendingPathExtension("list")!
    }
}
