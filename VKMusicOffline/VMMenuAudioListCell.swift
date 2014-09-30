//
//  VMMenuAudioListCell.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 25.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import UIKit

class VMMenuAudioListCell: UITableViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    // MARK: - VMAudioList
    var audioList: VMAudioList! {
        willSet (newValue) {
            if let list = newValue {
                self.titleLabel.text = list.title
                self.countLabel.text = "\(list.count)"
            }
        }
    }
    
    // MARK: - Overrides
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
