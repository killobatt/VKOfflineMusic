//
//  AudioPlayingCell.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 20.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import UIKit

class AudioPlayingCell: VMAudioCell {
    
    // MARK: - Outlets

    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var progressSlider: UISlider!
    
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
        
    }
    
    @IBAction func progressSliderMoved(sender: AnyObject) {
        
    }
}
