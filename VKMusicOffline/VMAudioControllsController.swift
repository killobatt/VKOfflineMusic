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
    
    // MARK: - Outlets
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var trackTitleLabel: UILabel!
    @IBOutlet private weak var trackArtistLabel: UILabel!
    @IBOutlet private weak var trackDurationLabel: UILabel!
    @IBOutlet private weak var trackRemainingDurationLabel: UILabel!
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var progressSlider: PlayerSlider!
    @IBOutlet weak var shuffleButton: UIButton!
    
    private var lyricsController: VMLyricsController!
    
    // MARK: - Privates
    private var progressSliderIsBeingMoved: Bool = false
    private var player: VMAudioListPlayer {
        get {
            return VMAudioListPlayer.sharedInstance
        }
    }
    
    // MARK: - UIViewController
    
    deinit {
        self.player.removeObserver(self, forKeyPath: "currentTrack")
        self.player.removeObserver(self, forKeyPath: "playbackProgress")
        self.player.removeObserver(self, forKeyPath: "loadedTrackPartTimeRange")
        self.player.removeObserver(self, forKeyPath: "isPlaying")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.player.addObserver(self, forKeyPath: "currentTrack", options: [.New, .Initial], context: nil)
        self.player.addObserver(self, forKeyPath: "playbackProgress", options: [.New, .Initial], context: nil)
        self.player.addObserver(self, forKeyPath: "loadedTrackPartTimeRange", options: [.New, .Initial], context: nil)
        self.player.addObserver(self, forKeyPath: "isPlaying", options: [.New, .Initial], context: nil)
        
        self.updateForTrack(self.player.currentTrack)
        self.progressSlider.value = 0
        self.progressSlider.secondaryValue = 0
        
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
    
    @IBAction func shuffleButtonTouchUpInside(sender: AnyObject) {
        let player = VMAudioListPlayer.sharedInstance
        if player.shuffleMode == .NoShuffle {
            player.shuffleMode = .RandomShuffle
        } else {
            player.shuffleMode = .NoShuffle
        }
        self.updateShuffleButton()
    }
    
    private func updateForTrack(currentTrack: VMAudio?) {
        UIView.animateWithDuration(0.25, animations: {
            if let track = currentTrack {
                self.trackTitleLabel.text = track.title as String
                self.trackArtistLabel.text = track.artist as String
                self.lyricsController.lyrics = track.lyrics
                self.progressSlider.minimumValue = 0
                self.progressSlider.maximumValue = Float(track.duration)
            } else {
                self.trackTitleLabel.text = ""
                self.trackArtistLabel.text = ""
                self.lyricsController.lyrics = nil
                self.progressSlider.minimumValue = 0
                self.progressSlider.maximumValue = 1
            }
        })
        self.trackDurationLabel.text = "-:--"
        self.trackRemainingDurationLabel.text = "-:--"
    }
    
    private func updateShuffleButton() {
        self.shuffleButton.selected = (VMAudioListPlayer.sharedInstance.shuffleMode == .RandomShuffle)
        self.shuffleButton.backgroundColor = (VMAudioListPlayer.sharedInstance.shuffleMode == .NoShuffle) ? UIColor.clearColor() : UIColor.lightGrayColor()
        self.shuffleButton.layer.cornerRadius = 5
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedLyrics" {
            if let lyricsController = segue.destinationViewController as? VMLyricsController  {
                self.lyricsController = lyricsController
                if let lyrics = self.player.currentTrack?.lyrics {
                    self.lyricsController.lyrics = lyrics
                }
            }
        }
    }
    
    
    // MARK: - KVO
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?,
        change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
            
            if (keyPath == "currentTrack") {
                self.updateForTrack(self.player.currentTrack)
            } else if (keyPath == "playbackProgress") {
                if (self.progressSliderIsBeingMoved == false) {
                    self.progressSlider.value = Float(CMTimeGetSeconds(self.player.playbackProgress))
                }
                
                if let playbackProgress = VMAudioControllsController.secondsFrom(time: self.player.playbackProgress) {
                    
                    if let currentTrack = self.player.currentTrack {
                        let totalDuration = currentTrack.duration
                        self.trackDurationLabel.text = VMAudioControllsController.durationString(playbackProgress)
                        self.trackRemainingDurationLabel.text = VMAudioControllsController.durationString(totalDuration - playbackProgress)
                    }
                } else {
                    self.trackDurationLabel.text = "-:--"
                    self.trackRemainingDurationLabel.text = "-:--"
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
    
    private class func secondsFrom(time time: CMTime) -> Int? {
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
            return NSString(format: "%d:%02d:%02d", hours, minutes, seconds) as String
        } else {
            return NSString(format: "%d:%02d", minutes, seconds) as String
        }
    }

}
