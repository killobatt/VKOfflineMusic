//
//  VMFriendCell.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodko on 01.08.15.
//  Copyright (c) 2015 Vjacheslav Volodko. All rights reserved.
//

import UIKit
import VK
import UIViews

class VMFriendCell: UITableViewCell {
    
    // MARK: - Model
    
    var user: VKUser? = nil {
        didSet {
            self.updateUI()
        }
    }
    
    // MAKR: - IBOutlets
    
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var avatarImageView: URLImageView!
    
    // MARK: - UITableViewCell

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: -
    
    func updateUI() {
        if let user = self.user {
            self.firstNameLabel.text = user.first_name
            self.lastNameLabel.text = user.last_name
            self.avatarImageView.imageURL = NSURL(string: user.photo_100)
        }
    }

}
