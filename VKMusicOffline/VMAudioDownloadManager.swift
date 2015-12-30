//
//  VMAudioDownloadManager.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodko on 25.06.15.
//  Copyright (c) 2015 Vjacheslav Volodko. All rights reserved.
//

import Foundation

@objc
protocol VMAudioDownloadManagerDelegate {
    optional func downloadManager(downloadManager:VMAudioDownloadManager, didLoadFile url:NSURL, forAudioWithID audioID:NSNumber)
    optional func downloadManager(downloadManager:VMAudioDownloadManager, didLoadLyrics lyrics:VMLyrics, forAudio audio:VMAudio)
}

@objc
protocol VMAudioDownloadManagerProgressDelegate {
    optional func downloadManager(downloadManager:VMAudioDownloadManager, loadedBytes bytesLoaded:Int64, fromTotalBytes totalBytes:Int64, forAudioWithID audioID:NSNumber, andTask task:NSURLSessionDownloadTask)
    optional func downloadManager(downloadManager:VMAudioDownloadManager, didLoadAudioWithID audioID:NSNumber, andTask task:NSURLSessionDownloadTask)
}

class VMAudioDownloadManager: NSObject, NSURLSessionDownloadDelegate {
    
    weak var delegate: VMAudioDownloadManagerDelegate? = nil
    weak var progressDelegate: VMAudioDownloadManagerProgressDelegate? = nil
   
    var URLSession: NSURLSession?
    
    var backgroundURLSessionCompletionHandler: (() -> Void)?
    
    init(delegate: VMAudioDownloadManagerDelegate?) {
        super.init()
        
        self.delegate = delegate
        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("com.vv.vkmusic-offline")
        configuration.HTTPMaximumConnectionsPerHost = 1
        self.URLSession = NSURLSession(configuration: configuration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())

    }
    
    func downloadAudio(audio:VMAudio) {
        if audio.localFileExists {
            return
        }
        
        if let downloadTask = self.URLSession?.downloadTaskWithURL(audio.URL) {
            downloadTask.taskDescription = audio.id.stringValue
            downloadTask.resume()
        }
        if let lyrics = audio.lyrics {
            if lyrics.text == nil {
                lyrics.loadText { (error: NSError!) -> Void in
                    self.delegate?.downloadManager?(self, didLoadLyrics: lyrics, forAudio: audio)
                }
            }
        }
    }
    
    func getAudioDownloadTaskList(completion: ((downloadTasks:[AnyObject]) -> Void)?) {
        self.URLSession?.getTasksWithCompletionHandler() { (dataTasks: [NSURLSessionDataTask], uploadTasks: [NSURLSessionUploadTask], downloadTasks: [NSURLSessionDownloadTask]) -> Void in
            completion?(downloadTasks: downloadTasks)
        }
    }
    
    func audioIDForTask(task: NSURLSessionTask) -> NSNumber? {
        if let taskDescription = task.taskDescription,
            audioIDint = Int(taskDescription) {
                return NSNumber(long: audioIDint)
        } else {
            return nil
        }
    }
    
    // MARK: - NSURLSessionDownloadDelegate
    
    /* Sent when a download task that has completed a download.  The delegate should
    * copy or move the file at the given location to a new location as it will be
    * removed when the delegate message returns. URLSession:task:didCompleteWithError: will
    * still be called.
    */
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        NSLog("URLSession downloadTask: \(downloadTask.taskIdentifier) didFinishDownloadingToURL: \(location)")
        if let audioID = self.audioIDForTask(downloadTask) {
            self.delegate?.downloadManager?(self, didLoadFile: location, forAudioWithID: audioID)
            self.progressDelegate?.downloadManager?(self, didLoadAudioWithID: audioID, andTask: downloadTask)
        }
    }
    
    /* Sent periodically to notify the delegate of download progress. */
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
//        NSLog("URLSession downloadTask: \(downloadTask.taskIdentifier) didWriteData: \(bytesWritten) bytes, totalBytesWritten: \(totalBytesWritten), totalBytesExpectedToWrite: \(totalBytesExpectedToWrite)")
        if let audioID = self.audioIDForTask(downloadTask) {
            self.progressDelegate?.downloadManager?(self, loadedBytes: totalBytesWritten, fromTotalBytes: totalBytesExpectedToWrite, forAudioWithID: audioID, andTask:downloadTask)
        }
    }
    
    /* Sent when a download has been resumed. If a download failed with an
    * error, the -userInfo dictionary of the error will contain an
    * NSURLSessionDownloadTaskResumeData key, whose value is the resume
    * data.
    */
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        NSLog("URLSession downloadTask: \(downloadTask.taskIdentifier) didResumeAtOffset: \(fileOffset) bytes, expectedTotalBytes: \(expectedTotalBytes) bytes")
    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        NSLog("URLSessionDidFinishEventsForBackgroundURLSession: \(session.configuration.identifier)")
        self.backgroundURLSessionCompletionHandler?()
    }

}
