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
        willSet {
            if (newValue != nil) {
                newValue.addObserver(self, forKeyPath: "title", options: nil, context: nil)
                newValue.addObserver(self, forKeyPath: "totalCount", options: nil, context: nil)
            }
        }
        didSet {
            if (oldValue != nil) {
                oldValue.removeObserver(self, forKeyPath: "title")
                oldValue.removeObserver(self, forKeyPath: "totalCount")
            }
            self.updateUI()
        }
    }
    
    // MARK: - Overrides
    
    deinit {
        self.audioList = nil // calls removing observation
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateUI() {
        if self.audioList != nil {
            self.titleLabel.text = self.audioList.title
            self.countLabel.text = (self.audioList.totalCount > 0) ? "\(self.audioList.totalCount)" : ""
        }
    }
    
    // MARK: - NSKeyValueObserving
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        self.updateUI()
    }
}
