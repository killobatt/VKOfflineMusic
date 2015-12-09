//
//  VMAudioListPlayer.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodko on 30.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

class VMAudioListPlayer: NSObject {
    
    // MARK: - Singleton
    class var sharedInstance : VMAudioListPlayer {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : VMAudioListPlayer? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = VMAudioListPlayer()
        }
        return Static.instance!
    }
    
    // MARK: - Instance variables
    var audioList: VMAudioList? {
        willSet {
            if let _ = newValue {
                
            }
        }
    }
    
    private var player: AVPlayer? {
        willSet {
            if let playbackObserver: AnyObject = self.playbackObserver,
                player = self.player {
                    player.removeTimeObserver(playbackObserver)
                    self.playbackObserver = nil
            }
        }
    }
    
    private var playerItem: AVPlayerItem? {
        willSet {
            if let item = self.playerItem {
                item.removeObserver(self, forKeyPath: "status")
                NSNotificationCenter.defaultCenter().removeObserver(self,
                    name: AVPlayerItemDidPlayToEndTimeNotification,
                    object: item)
            }
        }
        didSet {
            if let item = self.playerItem {
                item.addObserver(self, forKeyPath: "status", options: [.New, .Initial], context: nil)
                NSNotificationCenter.defaultCenter().addObserver(self, selector:"playerItemDidPlayToEndTime",
                    name: AVPlayerItemDidPlayToEndTimeNotification, object: item)
            }
        }
    }

    // MARK: - State
    
    private(set) var isPlaying: Bool = false {
        willSet {
            self.willChangeValueForKey("isPlaying")
        }
        didSet {
            self.updateNowPlayingInfoCenter()
            self.didChangeValueForKey("isPlaying")
        }
    }
    
    private(set) var playbackProgress : CMTime = kCMTimeZero {
        willSet {
            self.willChangeValueForKey("playbackProgress")
        }
        didSet {
            self.didChangeValueForKey("playbackProgress")
        }
    }

    
    var volume: Float = 1.0 {
        willSet {
            self.willChangeValueForKey("volume")
            self.player?.volume = newValue
        }
        didSet {
            self.didChangeValueForKey("volume")
        }
    }
    
    enum ShufflingMode {
        case NoShuffling
        case RandomShufling
    }
    
    var shufflingMode: ShufflingMode = ShufflingMode.NoShuffling{
        willSet {
            self.willChangeValueForKey("shufflingMode")
        }
        didSet {
            self.didChangeValueForKey("shufflingMode")
        }
    }
    
    private(set) var loadedTrackPartTimeRange: CMTimeRange = kCMTimeRangeZero {
        willSet {
            self.willChangeValueForKey("loadedTrackPartTimeRange")
        }
        didSet {
            self.didChangeValueForKey("loadedTrackPartTimeRange")
        }
    }
    
    enum State {
        case Idle
        case ReadyToPlay
        case Failed(error: NSError!)
        case RecoveringFromError(error: NSError!)
    }
    
    private(set) var state: State = State.Idle {
        willSet {
            self.willChangeValueForKey("state")
        }
        didSet {
            self.didChangeValueForKey("state")
        }
    }
    
    // MARK: - Player interface
    
    func setAudioList(audioList: VMAudioList, currentTrackIndex index: Int) {
        self.audioList = audioList
        self.currentTrackIndex = index
        if let audioList = self.audioList {
            self.audioListEnumerator = VMCycledDirectAudioListEnumerator(audioList: audioList, currentIndex:index)
        }
    }
    
    func play() {
        NSLog("VMAudioListPlayer play")
        self.player?.play()
        self.isPlaying = true
        
        var error: NSError? = nil
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
        } catch let error1 as NSError {
            error = error1
            NSLog("Could not activate audio session: \(error)")
            self.pause()
        }
    }
    
    func pause() {
        NSLog("VMAudioListPlayer pause")
        self.player?.pause()
        self.isPlaying = false
    }
    
    func seekToTime(time:CMTime) {
        if let player = self.player where player.status == AVPlayerStatus.ReadyToPlay {
            if (self.isPlaying) {
                player.pause()
            }
            player.currentItem?.cancelPendingSeeks()
            player.currentItem?.seekToTime(time, completionHandler: { (finished: Bool) -> Void in
                if (self.isPlaying) {
                    player.play()
                    self.updateNowPlayingInfoCenter()
                }
            })
        }
    }
    
    func playNextTrack() {
        if let newTrackIndex = self.audioListEnumerator?.nextIndex {
            self.currentTrackIndex = newTrackIndex
        } else {
            NSLog("Error: VMAudioListPlayer has no audioListEnumerator")
        }
    }
    
    func playPreviousTrack() {
        if let newTrackIndex = self.audioListEnumerator?.previousIndex {
            self.currentTrackIndex = newTrackIndex
        } else {
            NSLog("Error: VMAudioListPlayer has no audioListEnumerator")
        }
    }
    
    var currentTrack: VMAudio? {
        get {
            if let audioList = self.audioList
                where 0 <= self.currentTrackIndex && self.currentTrackIndex <= audioList.count {
                    return audioList[self.currentTrackIndex]
            } else {
                return nil
            }
        }
    }
    
    var currentTrackIndex: Int {
        get {
            if let audioListEnumerator = self.audioListEnumerator {
                return audioListEnumerator.currentIndex
            } else {
                return 0
            }
        }
        set(newValue) {
            self.willChangeValueForKey("currentTrackIndex")
            self.willChangeValueForKey("currentTrack")
            self.loadedTrackPartTimeRange = kCMTimeRangeZero
            self.playbackProgress = kCMTimeZero
            
            if var audioListEnumerator = self.audioListEnumerator {
                audioListEnumerator.currentIndex = newValue
            }
            
            self.didChangeValueForKey("currentTrackIndex")
            self.didChangeValueForKey("currentTrack")
            self.updateCurrentPlayerItem()
        }
    }
    
    private func updateCurrentPlayerItem() {
        if let currentTrack = self.currentTrack {
            if let localURL = currentTrack.localURL {
                self.playerItem = AVPlayerItem(URL: localURL)
            } else {
                self.playerItem = AVPlayerItem(URL: currentTrack.URL)
            }
            
            self.player = AVPlayer(playerItem: self.playerItem!)
            self.player?.actionAtItemEnd = AVPlayerActionAtItemEnd.Pause
            self.updateNowPlayingInfoCenter()
        }
    }
    
    // MARK: - Privates
    
    private var audioListEnumerator: VMAudioListEnumerator? = nil
    
    
    private func timeRangeFrom(timeRanges: NSArray) -> CMTimeRange {
        var loadedTrackPartTimeRange = kCMTimeRangeZero
        // TODO: Fix logic to more correct
        for value in timeRanges {
            let timeRange = (value as! NSValue).CMTimeRangeValue
            if (CMTimeGetSeconds(timeRange.duration) >
                CMTimeGetSeconds(loadedTrackPartTimeRange.duration)) {
                loadedTrackPartTimeRange = timeRange
            }
        }
        return loadedTrackPartTimeRange
    }
    
    private var playbackObserver: AnyObject!
    
    private func updateNowPlayingInfoCenter() {
        var nowPlayingInfo: [String : AnyObject] = [:]
        if let artist = self.currentTrack?.artist {
            nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        }
        if let title = self.currentTrack?.title {
            nowPlayingInfo[MPMediaItemPropertyTitle] = title
        }
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = NSNumber(integer: self.currentTrack!.duration)
        // set once in the start of the playback, the system will update this automatically
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(double: CMTimeGetSeconds(self.playbackProgress))
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = nowPlayingInfo
    }
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        self.setupAudioSession()
    }
    
    deinit {
        self.interruptionNotificationObserver = nil
        self.playbackObserver = nil
    }
    
    // MARK: - KVO
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if object is AVPlayerItem {
            let playerItem = object as! AVPlayerItem
            if keyPath == "status" {
                switch playerItem.status {
                case AVPlayerItemStatus.ReadyToPlay:
                    NSLog("VMAudioListPlayer: AVPlayerItem ready to play")
                    self.state = State.ReadyToPlay
                    
                    let timeInterval = CMTimeMakeWithSeconds(0.1, 600)
                    self.playbackObserver = self.player?.addPeriodicTimeObserverForInterval(timeInterval, queue: dispatch_get_main_queue()) { (time: CMTime) -> Void in
                        if let playerItem = self.playerItem {
                            self.playbackProgress = playerItem.currentTime()
                            self.loadedTrackPartTimeRange = self.timeRangeFrom(playerItem.loadedTimeRanges)
                        }
                    }
                    
                    if (self.isPlaying) {
                        self.player?.play()
                    }
                    self.updateNowPlayingInfoCenter()
                case AVPlayerItemStatus.Failed:
                    NSLog("VMAudioListPlayer: AVPlayerItem: Failed with error \(playerItem.error)")
                    switch self.state {
                        case .RecoveringFromError(_):
                            self.state = State.Failed(error: playerItem.error)
                            self.playNextTrack()
                        case .Idle, .ReadyToPlay, .Failed(_):
                            self.state = State.RecoveringFromError(error: playerItem.error)
                            self.currentTrack?.refreshURL() {
                                (refreshedAudio: VMAudio?, error: NSError?) -> () in
                                if let audio = refreshedAudio {
                                    // if offline track is broken, redownload it
                                    audio.localFileName = nil
                                    VMAudioListManager.sharedInstance.downloadManager.downloadAudio(audio)
                                } else {
                                    self.state = State.Failed(error: playerItem.error)
                                    self.playNextTrack()
                                }
                                self.updateCurrentPlayerItem()
                                self.play()
                            }
                    }
                    self.player = nil
                case AVPlayerItemStatus.Unknown:
                    NSLog("VMAudioListPlayer: AVPlayerItem: Unknown status, eror \(playerItem.error)")
                    self.state = .Idle
                    self.player = nil
                }
            }
        }
    }

    func playerItemDidPlayToEndTime() {
        self.playNextTrack()
    }
    
    // MARK: AudioSession
    
    func setupAudioSession() {
        var error: NSError? = nil
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        } catch let error1 as NSError {
            error = error1
            NSLog("Error setting AVAudioSession category \(AVAudioSessionCategoryPlayback): \(error)")
        }
        
        
        self.interruptionNotificationObserver = NSNotificationCenter.defaultCenter().addObserverForName(AVAudioSessionInterruptionNotification, object: nil, queue: NSOperationQueue.mainQueue()) {
            (notification: NSNotification) -> Void in
            NSLog("Got interruption: \(notification.userInfo)")
            
            let rawValueNumber = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber
            if let rawValue = rawValueNumber?.unsignedIntegerValue {
                if let interruptionType = AVAudioSessionInterruptionType(rawValue: UInt(rawValue)) {
                    switch interruptionType {
                    case AVAudioSessionInterruptionType.Began:
                        if (self.isPlaying) {
                            NSLog("Interruption began. Pausing...")
                            self.player?.pause()
                        }
                    case AVAudioSessionInterruptionType.Ended:
                        if (self.isPlaying) {
                            NSLog("Interruption ended. Resuming...")
                            self.player?.play()
                        }
                    }
                }
            }
        }
    }
    
    private var interruptionNotificationObserver: AnyObject!
}
