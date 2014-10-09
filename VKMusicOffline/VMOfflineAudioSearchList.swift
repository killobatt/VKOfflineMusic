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
    
    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!,
        change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<Void>) {
        if (keyPath == "audios") {
            self.filteredAudios = self.getFilteredAudios(self.originalList.audios, searchTerm: self.searchTerm)
        }
    }
    
    // MARK: - VMAudioListSearching
    
    override var audios : Array<VMAudio> {
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
    
    private var filteredAudios: Array<VMAudio> = []
    
    private func getFilteredAudios(audios: Array<VMAudio>, searchTerm: String!) -> Array<VMAudio> {
        if searchTerm == nil {
            return audios
        } else {
            return audios.filter{ VMAudio -> Bool in
                return VMAudio.title.localizedCaseInsensitiveContainsString(searchTerm) ||
                    VMAudio.artist.localizedCaseInsensitiveContainsString(searchTerm)
            }
        }
    }
}
