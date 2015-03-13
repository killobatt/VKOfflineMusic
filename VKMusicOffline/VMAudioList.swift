//
//  VMAudioList.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodjko on 20.09.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation
import VK

class VMAudioList: NSObject {
    
    var audios : Array<VMAudio> = []
    
    var title : NSString!
   
    var searchResultsList: VMAudioList? {
        get {
            return nil
        }
    }
    
    subscript(index: Int) -> VMAudio {
        get {
            return self.audios[index]
        }
    }
    
    // number of audios in loaded part of list
    var count: Int {
        get {
            return self.audios.count
        }
    }
    
    // nuber of audios in both loaded and unloaded part of list
    dynamic var totalCount: Int = 0
    
    func hasNextPage() -> Bool { return false }
    func loadNextPage(#completion:((NSError!) -> Void)?) -> Void { }
    
}


// Editable list
extension VMAudioList {
    
    func moveTrackFromIndex(index:Int, toIndex:Int) { }
    func deleteTrackAtIndex(index:Int) { }
    
    func editingEnabled() -> Bool { return false }
    
}
