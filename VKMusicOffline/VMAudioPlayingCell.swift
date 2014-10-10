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
        VMAudioListPlayer.sharedInstance.playbackProgress = time
    }
    
    // MARK: - KVO
    
    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!,
        change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<Void>) {
            if (keyPath == "playbackProgress") {
                self.progressSlider.value = Float(CMTimeGetSeconds(VMAudioListPlayer.sharedInstance.playbackProgress))
            } else if keyPath == "loadedTrackPartTimeRange" {
                self.progressSlider.secondaryValue = Float(CMTimeGetSeconds(VMAudioListPlayer.sharedInstance.loadedTrackPartTimeRange.duration))
            } else if keyPath == "isPlaying" {
                self.pauseButton.titleLabel?.text = VMAudioListPlayer.sharedInstance.isPlaying ? "Pause" : "Play"
            }
    }
}
