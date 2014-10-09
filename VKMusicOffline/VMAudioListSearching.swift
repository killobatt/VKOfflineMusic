//
//  VMAudioListSearching.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodko on 09.10.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation

@objc protocol VMAudioListSearching {
    var searchTerm: NSString! {
        get
    }
    
    func setSearchTerm(searchTerm: NSString!, completion:((NSError!) -> Void)?) -> Void
}