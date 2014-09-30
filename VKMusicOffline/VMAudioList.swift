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
    
    var audios : Array< VMAudio > = []
    
    var title : NSString!
    
    subscript(index: Int) -> VMAudio {
        get {
            return audios[index]
        }
        set (newValue) {
            audios[index] = newValue
        }
    }
    
    var count: Int {
        get {
            return self.audios.count
        }
    }
    
    func hasNextPage() -> Bool { return false }
    func loadNextPage(#completion:((NSError!) -> Void)?) -> Void { }
}
