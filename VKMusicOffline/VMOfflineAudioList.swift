//
//  VMAudioList.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 24.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation

class VMOfflineAudioList: VMAudioList, NSCoding {
    
    var identifier: NSUUID
    
    // MARK: - NSCoding interface implementation
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.identifier, forKey:"identifier")
        aCoder.encodeObject(self.title, forKey:"title")
    }
    
    required init(coder aDecoder: NSCoder) {
        self.identifier = aDecoder.decodeObjectForKey("identifier") as NSUUID
        super.init()
        self.title = aDecoder.decodeObjectForKey("title") as NSString
    }

    // MARK: - VMAudio overrides
    
    override var searchResultsList: VMAudioList? {
        get {
            return VMOfflineAudioSearchList(offlineAudioList: self)
        }
    }
}
