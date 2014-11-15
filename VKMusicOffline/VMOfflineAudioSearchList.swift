//
//  VMOfflineAudioSearchList.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodko on 09.10.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation

class VMOfflineAudioSearchList: VMAudioList, VMAudioListSearching {
 
    private var originalList: VMOfflineAudioList
 
    init(offlineAudioList: VMOfflineAudioList) {
        self.originalList = offlineAudioList
        super.init()
        self.originalList.addObserver(self, forKeyPath: "audios", options:nil, context: nil)
    }
    
    deinit {
        self.originalList.removeObserver(self, forKeyPath: "audios")
    }
    
    // MARK: - NSKeyValueObserving
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject,
        change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if (keyPath == "audios") {
            self.filteredAudios = self.getFilteredAudios(self.originalList.audios, searchTerm: self.searchTerm)
        }
    }
    
    // MARK: - VMAudioListSearching
    
    override var audios : NSArray {
        get {
            return self.filteredAudios
        }
        set {
            assert(false, "Cannot set audios for search list");
        }
    }
    
    var searchTerm: NSString! {
        didSet {
            self.filteredAudios = self.getFilteredAudios(self.originalList.audios,
                searchTerm: self.searchTerm)
        }
    }
    
    func setSearchTerm(searchTerm: NSString!, completion:((NSError!) -> Void)?) -> Void {
        self.searchTerm = searchTerm;
        if let _completion = completion {
            _completion(nil)
        }
    }
    
    private var filteredAudios: NSArray = []
    
    private func getFilteredAudios(audios: NSArray, searchTerm: String!) -> NSArray {
        if searchTerm == nil {
            return audios
        } else {
            return audios.filteredArrayUsingPredicate(
                NSPredicate(block:
                    { (object: AnyObject!, bindings:[NSObject : AnyObject]!) -> Bool in
                        let audio = object as VMAudio
                        return audio.title.localizedCaseInsensitiveContainsString(searchTerm) ||
                            audio.artist.localizedCaseInsensitiveContainsString(searchTerm)
                    }
                )
            )
        }
    }
}
