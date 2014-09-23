//
//  AudioCell.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 20.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import UIKit

class AudioCell: UITableViewCell {
    
    // MARK: - Audio
    var audio: VKOfflineAudio! {
        willSet(newAudio) {
            if (newAudio) {
                self.artistNameLabel.text = newAudio.artist
                self.trackNameLabel.text = newAudio.title
                self.trackDurationLabel.text = newAudio.durationString
                if (newAudio.lyricsID) {
                    self.lyricsButton.enabled = true
                } else {
                    self.lyricsButton.enabled = false
                }
            }
        }
    }
    
    // MARK: - IBOutlets

    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var trackDurationLabel: UILabel!
    @IBOutlet weak var lyricsButton: UIButton!
    
    // MARK: - Overrides
    
    init(style: UITableViewCellStyle, reuseIdentifier: String) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Initialization code
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
    
    @IBAction func lyricsButtonPressed(sender: AnyObject) {
    }
}
