//
//  MenuUserInfoCell.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 25.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import UIKit
import VK

class MenuUserInfoCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    // MARK: - VKUser
    var user : VKUser! {
        willSet (newUser) {
            if (newUser != nil) {
                self.firstNameLabel.text = newUser.first_name
                self.lastNameLabel.text = newUser.last_name
                NSURLSession.sharedSession().dataTaskWithURL(NSURL.URLWithString(newUser.photo_100),
                    completionHandler: {(data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
                        let img: UIImage = UIImage(data: data)
                        self.userImageView.image = img
                })
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
