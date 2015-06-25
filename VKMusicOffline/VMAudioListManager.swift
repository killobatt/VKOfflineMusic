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

class VMAudioListManager: NSObject, NSURLSessionDownloadDelegate {
   
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
        self.model = CDModel(storageURL:self.audioListModelURL)
        
        self.loadOfflineAudioLists()
        
//        self.loadLegacyOfflineAudioLists()
        
        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("com.vv.vkmusic-offline")
        self.URLSession = NSURLSession(configuration: configuration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
    }
    
    deinit {
        self.saveOfflineAudioLists()
    }
    
    // MARK: - Audio List Storage
    
    var model: CDModel!
    
    // MARK: - VMAudioLists
    var userAudioList: VMUserAudioList!
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
        let listPath = self.pathForList(list)
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
            let path = self.pathForList(list)
            NSLog("Saving list '\(list.title)' with \(list.audios.count) audios to file '\(path)'...")
            NSKeyedArchiver.archiveRootObject(list, toFile: path)
        }
    }
    
    func loadLegacyOfflineAudioLists() {
        self.offlineAudioLists = []
        
        let fileManager = NSFileManager.defaultManager()
        var audioListsDirExists = fileManager.fileExistsAtPath(self.offlineAudioListDirectoryPath)
        if (audioListsDirExists) {
            
            NSLog("Scanning folder '\(self.offlineAudioListDirectoryPath)' for lists...")
            var error: NSError? = nil
            let paths = fileManager.contentsOfDirectoryAtPath(self.offlineAudioListDirectoryPath, error: &error) as! [String]?
            if (error != nil) {
                NSLog("Error loading contents of dir \(self.offlineAudioListDirectoryPath) : \(error)")
                return
            }
            
            if let listsFileNames = paths {
                for listFileName in listsFileNames {
                    let listPath = self.offlineAudioListDirectoryPath.stringByAppendingPathComponent(listFileName)
                    if (listPath.pathExtension != "list") {
                        continue
                    }
                    NSLog("Loading list from file '\(listPath)'...")
                    var list = NSKeyedUnarchiver.unarchiveObjectWithFile(listPath) as! VMOfflineAudioList
                    self.offlineAudioLists.append(list)
                    NSLog("Loaded list '\(list.title)' with \(list.audios.count) audios")
                }
            }
        }
    }
    
    func loadOfflineAudioLists() {
        let audioLists = self.model.audioLists
        
        self.offlineAudioLists = []
        for storedAudioList in audioLists {
            let list = VMOfflineAudioList(storedAudioList: storedAudioList)
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
        return NSURL(fileURLWithPath: self.offlineAudioListDirectoryPath.stringByAppendingPathComponent("audio-list-model.sqlite"))!
    }
    
    var offlineAudioListDirectoryPath: String {
        get {
            let dirs = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,
                NSSearchPathDomainMask.UserDomainMask, true)
            let userDocumentsDirectory = dirs[0] as! String
            return userDocumentsDirectory.stringByAppendingPathComponent("audio-lists")
        }
    }
    
    func pathForList(list: VMOfflineAudioList) -> String {
        let path = self.offlineAudioListDirectoryPath.stringByAppendingPathComponent(list.identifier.UUIDString)
        return path.stringByAppendingPathExtension("list")!
    }
    
    // MARK: - Downloading
    
    var URLSession: NSURLSession?
    
    var backgroundURLSessionCompletionHandler: (() -> Void)?
    
    private var downloadTasks: Dictionary<Int, NSNumber> = Dictionary() // download task id, audio id
    
    func downloadAudio(audio:VMAudio) {
        if (audio.localFileName != nil) {
            return
        }
        let downloadTaskOptional = self.URLSession?.downloadTaskWithURL(audio.URL)
        if let downloadTask = downloadTaskOptional {
            self.downloadTasks[downloadTask.taskIdentifier] = audio.id
            downloadTask.taskDescription = audio.formattedTitle as String
            downloadTask.resume()
        }
        if let lyrics = audio.lyrics {
            if lyrics.text == nil {
                lyrics.loadText { (error: NSError!) -> Void in
                    self.saveOfflineAudioLists()
                }
            }
        }
    }
    
    func getAudioDownloadTaskList(completion: ((downloadTasks:[AnyObject]) -> Void)?) {
        self.URLSession?.getTasksWithCompletionHandler({ (dataTasks: [AnyObject]!, uploadTasks: [AnyObject]!, downloadTasks: [AnyObject]!) -> Void in
            if (downloadTasks != nil) {
                completion?(downloadTasks: downloadTasks)
            }
        })
    }
    
    // MARK: - NSURLSessionDownloadDelegate
    
    /* Sent when a download task that has completed a download.  The delegate should
    * copy or move the file at the given location to a new location as it will be
    * removed when the delegate message returns. URLSession:task:didCompleteWithError: will
    * still be called.
    */
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        if let audioID = self.downloadTasks[downloadTask.taskIdentifier] {
            let audioFileName = audioID.stringValue.stringByAppendingPathExtension("mp3")
            let audioPath = self.offlineAudioListDirectoryPath.stringByAppendingPathComponent(audioFileName!)
            if let audioURL = NSURL(fileURLWithPath:audioPath) {            
                var error: NSError?
                NSFileManager.defaultManager().moveItemAtURL(location, toURL: audioURL, error: &error)
                for list in self.offlineAudioLists {
                    for audio in list.audios {
                        if (audio as! VMAudio).id == audioID {
                            (audio as! VMAudio).localFileName = audioFileName
                        }
                    }
                }
            }
            self.saveOfflineAudioLists()
        }
    }
    
    /* Sent periodically to notify the delegate of download progress. */
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        NSLog("URLSession downloadTask \(downloadTask.taskIdentifier) didWriteData \(bytesWritten) bytes, totalBytesWritten \(totalBytesWritten), totalBytesExpectedToWrite \(totalBytesExpectedToWrite)")
    }
    
    /* Sent when a download has been resumed. If a download failed with an
    * error, the -userInfo dictionary of the error will contain an
    * NSURLSessionDownloadTaskResumeData key, whose value is the resume
    * data.
    */
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        self.backgroundURLSessionCompletionHandler!()
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
