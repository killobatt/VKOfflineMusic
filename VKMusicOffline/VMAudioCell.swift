//
//  VMAudioCell.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 20.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import UIKit

class VMAudioCell: UITableViewCell {
    
    // MARK: - Audio
    var audio: VMAudio! {
        willSet(newAudio) {
            if (newAudio != nil) {
                self.artistNameLabel.text = newAudio.artist
                self.trackNameLabel.text = newAudio.title
                self.trackDurationLabel.text = newAudio.durationString
                if (newAudio.lyricsID != nil) {
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
    
    @IBAction func lyricsButtonPressed(sender: AnyObject) {
    }
}
