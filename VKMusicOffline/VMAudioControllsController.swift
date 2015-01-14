//
//  VMAudioControllsController.swift
//  VKMusicOffline
//
//  Created by Guest on 10/01/15.
//  Copyright (c) 2015 Vjacheslav Volodko. All rights reserved.
//

import UIKit
import UIViews
import AVFoundation

class VMAudioControllsController: UIViewController {
    
    // MARK: - Public
    
    // MARK: Singleton
    class var sharedInstance : VMAudioControllsController {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : VMAudioControllsController? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = VMAudioControllsController()
        }
        return Static.instance!
    }
    
    // MARK: Window
    
    private class Window: UIWindow {
        
        override init() {
            super.init()
        }
        
        required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        private weak var controller: VMAudioControllsController!
        
        private override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
            let hitTestResult = VMAudioControllsController.sharedInstance.view.hitTest(point, withEvent: event)
            if hitTestResult === VMAudioControllsController.sharedInstance.view {
                return nil
            } else {
                return hitTestResult
            }
        }
    }
    
    private var window: Window? = nil
    
    func display() {
        if self.window == nil {
            self.window = Window()
            self.window?.rootViewController = self
            self.window?.windowLevel = UIWindowLevelAlert
            self.window?.makeKeyAndVisible()
            if let mainWindow = UIApplication.sharedApplication().delegate?.window {
                mainWindow?.makeKeyAndVisible()
            }
            
            
        }
    }

    // MARK: - Outlets
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var trackTitleLabel: UILabel!
    @IBOutlet private weak var trackArtistLabel: UILabel!
    @IBOutlet private weak var trackDurationLabel: UILabel!
    @IBOutlet private weak var trackRemainingDurationLabel: UILabel!
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var progressSlider: PlayerSlider!
    
    // MARK: - Privates
    private var progressSliderIsBeingMoved: Bool = false
    private var player: VMAudioListPlayer {
        get {
            return VMAudioListPlayer.sharedInstance
        }
    }
    
    // MARK: - UIViewController
    
    override var nibName: String? {
        get {
            return "VMAudioControllsController"
        }
    }
    
    deinit {
        self.player.removeObserver(self, forKeyPath: "currentTrack")
        self.player.removeObserver(self, forKeyPath: "playbackProgress")
        self.player.removeObserver(self, forKeyPath: "loadedTrackPartTimeRange")
        self.player.removeObserver(self, forKeyPath: "isPlaying")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.player.addObserver(self, forKeyPath: "currentTrack", options: nil, context: nil)
        self.player.addObserver(self, forKeyPath: "playbackProgress", options: nil, context: nil)
        self.player.addObserver(self, forKeyPath: "loadedTrackPartTimeRange", options: nil, context: nil)
        self.player.addObserver(self, forKeyPath: "isPlaying", options: nil, context: nil)
        
        self.trackTitleLabel.text = self.player.currentTrack.title
        self.trackArtistLabel.text = self.player.currentTrack.artist
        self.playPauseButton.selected = self.player.isPlaying
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func togglePlayPause(sender: AnyObject) {
        if (self.player.isPlaying) {
            self.player.pause()
        } else {
            self.player.play()
        }
    }
    
    @IBAction func playPreviousTrack(sender: AnyObject) {
        self.player.playPreviousTrack()
    }

    @IBAction func playNextTrack(sender: AnyObject) {
        self.player.playNextTrack()
    }
    
    @IBAction func progressSliderMoved(sender: PlayerSlider) {
        let timescale = 1 //self.player.currentItem.currentTime().timescale
        let value = Int(sender.value) * timescale
        let time = CMTimeMake(Int64(value), Int32(timescale))
        self.player.seekToTime(time)
    }
    
    @IBAction func progressSliderTouchDragInside(sender: AnyObject) {
        self.progressSliderIsBeingMoved = true
    }
    
    @IBAction func progressSliderTouchUpInside(sender: AnyObject) {
        self.progressSliderIsBeingMoved = false
    }
    
    @IBAction func progressSliderTouchUpOutside(sender: AnyObject) {
        self.progressSliderIsBeingMoved = false
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: - KVO
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject,
        change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
            
            if (keyPath == "currentTrack") {
                self.trackTitleLabel.text = self.player.currentTrack.title
                self.trackArtistLabel.text = self.player.currentTrack.artist
            } else if (keyPath == "playbackProgress") {
                if (self.progressSliderIsBeingMoved == false) {
                    self.progressSlider.value = Float(CMTimeGetSeconds(self.player.playbackProgress))
                }
                
                if let playbackProgress = VMAudioControllsController.secondsFrom(time: self.player.playbackProgress) {
                    let totalDuration = self.player.currentTrack.duration
                    self.trackDurationLabel.text = VMAudioControllsController.durationString(playbackProgress)
                    self.trackRemainingDurationLabel.text = VMAudioControllsController.durationString(totalDuration - playbackProgress)
                } else {
                    self.trackDurationLabel.text = ""
                    self.trackRemainingDurationLabel.text = ""
                }
                
                
            } else if keyPath == "loadedTrackPartTimeRange" {
                self.progressSlider.secondaryValue = Float(
                    CMTimeGetSeconds(self.player.loadedTrackPartTimeRange.start) +
                        CMTimeGetSeconds(self.player.loadedTrackPartTimeRange.duration))
            } else if keyPath == "isPlaying" {
                self.playPauseButton.selected = self.player.isPlaying
            }
    }
    
    // MARK: - Utils
    
    private class func secondsFrom(#time: CMTime) -> Int? {
        if CMTimeCompare(time, kCMTimeIndefinite) != 0 {
            return Int(CMTimeGetSeconds(time));
        } else {
            return nil
        }
    }
    
    private class func durationString(timeInSeconds: Int) -> String {
        let seconds = timeInSeconds % 60
        let minutes = (timeInSeconds / 60) % 60
        let hours = (timeInSeconds / 3600)
        if hours > 0 {
            return NSString(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return NSString(format: "%d:%02d", minutes, seconds)
        }
    }

}
