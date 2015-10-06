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
    var audio: VMAudio? {
        willSet(newAudio) {
            if let audio = newAudio {
                self.artistNameLabel.text = audio.artist as String
                self.trackNameLabel.text = audio.title as String
                self.trackDurationLabel.text = audio.durationString as String
                if let track = self.player.currentTrack {
                    self.playingIndicator.hidden = track != audio
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
    
    required init?(coder aDecoder: NSCoder) {
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
        self.player.addObserver(self, forKeyPath: "currentTrack", options: [.New], context: nil)
        self.player.addObserver(self, forKeyPath: "isPlaying", options: [.New], context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (keyPath == "currentTrack") {
            if let playerTrack = self.player.currentTrack,
                ourTrack = self.audio {
                    self.playingIndicator.hidden = ourTrack != playerTrack
            } else {
                self.playingIndicator.hidden = true
            }
        } else if (keyPath == "isPlaying") {
            
        }
    }

}
