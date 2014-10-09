//
//  VMAudioList.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 24.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation

class VMOfflineAudioList: VMAudioList, NSCoding {
    
    var name: NSString!
    var identifier: NSUUID
    
    // MARK: - NSCoding interface implementation
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.identifier, forKey: "identifier")
    }
    
    required init(coder aDecoder: NSCoder) {
        self.identifier = aDecoder.decodeObjectForKey("identifier") as NSUUID
    }

    // MARK: - VMAudio overrides
    
    override var searchResultsList: VMAudioList? {
        get {
            return VMOfflineAudioSearchList(offlineAudioList: self)
        }
    }
}
