//
//  NSKeyedArchiver+VM.swift
//  VKMusicOffline
//
//  Created by Vjacheslav Volodko on 16.10.14.
//  Copyright (c) 2014 Vjacheslav Volodko. All rights reserved.
//

import Foundation

extension NSCoder {
    func encodeOptional(optional:NSObject!, forKey key:String) {
        if optional != nil {
            self.encodeObject(optional, forKey: key)
        }
    }
}