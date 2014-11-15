//
//  AudioPlayingCell.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 20.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import UIKit
import UIViews
import AVFoundation

class VMAudioPlayingCell: VMAudioCell {
    
    // MARK: - Audio
    
    override var audio: VMAudio! {
        willSet(newAudio) {
            if (newAudio != nil) {
                self.progressSlider.minimumValue = 0
                self.progressSlider.maximumValue = Float(newAudio.duration)
                self.progressSlider.value = Float(CMTimeGetSeconds(VMAudioListPlayer.sharedInstance.playbackProgress))
                self.progressSlider.secondaryValue = Float(
                    CMTimeGetSeconds(VMAudioListPlayer.sharedInstance.loadedTrackPartTimeRange.start) +
                    CMTimeGetSeconds(VMAudioListPlayer.sharedInstance.loadedTrackPartTimeRange.duration))
                
                VMAudioListPlayer.sharedInstance.addObserver(self, forKeyPath: "playbackProgress", options: nil, context: nil)
                VMAudioListPlayer.sharedInstance.addObserver(self, forKeyPath: "loadedTrackPartTimeRange", options: nil, context: nil)
                VMAudioListPlayer.sharedInstance.addObserver(self, forKeyPath: "isPlaying", options: nil, context: nil)
            } else {
                VMAudioListPlayer.sharedInstance.removeObserver(self, forKeyPath: "playbackProgress")
                VMAudioListPlayer.sharedInstance.removeObserver(self, forKeyPath: "loadedTrackPartTimeRange")
                VMAudioListPlayer.sharedInstance.removeObserver(self, forKeyPath: "isPlaying")
            }
        }
    }
    
    // MARK: - Outlets

    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var progressSlider: PlayerSlider!
    
    // MARK! - Overrides
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Initialization code
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Actions
    
    var progressSliderIsBeingMoved = false
    
    @IBAction func pauseButtonPressed(sender: AnyObject) {
        if (VMAudioListPlayer.sharedInstance.isPlaying) {
            VMAudioListPlayer.sharedInstance.pause()
        } else {
            VMAudioListPlayer.sharedInstance.play()
        }
    }
    
    @IBAction func progressSliderMoved(sender: PlayerSlider) {
        let timescale = 1 //self.player.currentItem.currentTime().timescale
        let value = Int(sender.value) * timescale
        let time = CMTimeMake(Int64(value), Int32(timescale))
        VMAudioListPlayer.sharedInstance.seekToTime(time)
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
    
    
    // MARK: - KVO
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject,
        change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
            if (keyPath == "playbackProgress") {
                if (self.progressSliderIsBeingMoved == false) {
                    self.progressSlider.value = Float(CMTimeGetSeconds(VMAudioListPlayer.sharedInstance.playbackProgress))
                }
                self.trackDurationLabel.text = self.durationString(VMAudioListPlayer.sharedInstance.playbackProgress)
            } else if keyPath == "loadedTrackPartTimeRange" {
                self.progressSlider.secondaryValue = Float(
                    CMTimeGetSeconds(VMAudioListPlayer.sharedInstance.loadedTrackPartTimeRange.start) +
                    CMTimeGetSeconds(VMAudioListPlayer.sharedInstance.loadedTrackPartTimeRange.duration))
            } else if keyPath == "isPlaying" {
                self.pauseButton.setTitle(VMAudioListPlayer.sharedInstance.isPlaying ? "Pause" : "Play", forState:UIControlState.Normal)
            }
    }
    
    // MARK: - Utils
    
    func durationString(time: CMTime) -> String {
        if CMTimeCompare(time, kCMTimeIndefinite) != 0 {
            let timeInSeconds = Int(CMTimeGetSeconds(time));
            let seconds = timeInSeconds % 60
            let minutes = (timeInSeconds / 60) % 60
            let hours = (timeInSeconds / 3600)
            if hours > 0 {
                return NSString(format: "%d:%02d:%02d", hours, minutes, seconds)
            } else {
                return NSString(format: "%d:%02d", minutes, seconds)
            }
        } else {
            return ""
        }
        
    }
}
