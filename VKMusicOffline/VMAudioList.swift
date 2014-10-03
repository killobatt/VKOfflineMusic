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
    
    var audios : Array<VMAudio> = [] {
        didSet {
            self._filteredAudios = self.getFilteredAudios(self.audios,
                searchTerm: self.searchTerm)
        }
    }
    
    var title : NSString!
    
    var searchTerm: NSString! {
        didSet {
            self._filteredAudios = self.getFilteredAudios(self.audios,
                searchTerm: self.searchTerm)
        }
    }
    
    var filteredAudios: Array<VMAudio> {
        get {
            return self._filteredAudios
        }
    }
    
    private var _filteredAudios: Array<VMAudio> = []
    
    private func getFilteredAudios(audios: Array<VMAudio>, searchTerm: String!) -> Array<VMAudio> {
        if searchTerm == nil {
            return audios
        } else {
            return audios.filter{ VMAudio -> Bool in
                return VMAudio.title.containsString(searchTerm) ||
                    VMAudio.artist.containsString(searchTerm)
            }
        }
    }
    
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
