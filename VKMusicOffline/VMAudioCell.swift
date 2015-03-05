//
//  VMAudioCell.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 20.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import UIKit
import MGSwipeCells

class VMAudioCell: MGSwipeTableCell {
    
    // MARK: - Audio
    var audio: VMAudio! {
        willSet(newAudio) {
            if (newAudio != nil) {
                self.artistNameLabel.text = newAudio.artist as String
                self.trackNameLabel.text = newAudio.title as String
                self.trackDurationLabel.text = newAudio.durationString as String
                if let track = self.player.currentTrack {
                    self.playingIndicator.hidden = track != newAudio
                } else {
                    self.playingIndicator.hidden = true
                }
            }
        }
    }
    var player: VMAudioListPlayer {
        get {
            return VMAudioListPlayer.sharedInstance
        }
    }
    
    // MARK: - IBOutlets

    @IBOutlet private weak var artistNameLabel: UILabel!
    @IBOutlet private weak var trackNameLabel: UILabel!
    @IBOutlet private weak var trackDurationLabel: UILabel!
    @IBOutlet private weak var playingIndicator: UIImageView!
    
    // MARK: - Overrides
    
    deinit {
        self.player.removeObserver(self, forKeyPath: "currentTrack")
        self.player.removeObserver(self, forKeyPath: "isPlaying")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupObserving()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setupObserving()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    // MARK: - KVO
    
    private func setupObserving() {
        self.player.addObserver(self, forKeyPath: "currentTrack", options: nil, context: nil)
        self.player.addObserver(self, forKeyPath: "isPlaying", options: nil, context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if (keyPath == "currentTrack") {
            if let track = self.player.currentTrack {
                self.playingIndicator.hidden = self.audio != track
            }
        } else if (keyPath == "isPlaying") {
            
        }
    }

}
